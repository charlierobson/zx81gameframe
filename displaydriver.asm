;-------------------------------------------------------------------------------
;
.module	DISPLAY

; To install the display driver simply:
;	ld 	ix,DISPLAY._GENERATE

; Special thanks go to Paul Farrow.
;
; *******************************
; * ZX81 Lo-Res Display Drivers *
; *******************************
; (c)2022 Paul Farrow, www.fruitcake.plus.com
;
; You are free to use and modify these drivers in your own programs.

_GENERATE_VSYNC:
	IN		A,($FE)						; Start the VSync pulse.

	; The user actions must always take the same length of time.
	; Should be at least 3.3 scanlines (684 T-states) in duration for Chroma 81 compatibility.
	CALL	INPUT._read

	OUT		($FF),A						; End the VSync pulse.

	LD		HL,(frames)
	INC		HL
	LD		(frames),hl

	; top border

	LD		A,(margin)					; Fetch or specify the number of lines in the top border (must be a multiple of 8).
	LD		IX,_GENERATE				; Set the display routine pointer to generate the main picture area next.
	JP		$029E						; Commence generating the top border lines and return to the user program.

	; end top border

LBUF:
	LD		R,A							; HFILE address LSB -> R
	.fill	32,0
	RET		NZ							; always returns


_GENERATE:
	LD		B,7
-:	DJNZ	{-}

	DEC		B							; 0->ff resets Z flag, for ret nz instruction in d-file
	LD		HL,_screen
	LD		DE,$20
	LD		B,$C0

-:	LD		A,H
	LD		I,A
	LD		A,L
	CALL	LBUF + $8000
	ADD		HL,DE
	DEC		B
	JP		NZ,{-}

	; bottom border

	LD		A,(margin)					; Fetch or specify the number of lines in the bottom border (does not have to be a multiple of 8).
	NEG
	INC		A
	EX		AF,AF'

	OUT		($FE),A						; Turn on the NMI generator to commence generating the bottom border lines.

	; The user actions must not take longer than the time to generate the bottom border at either 50Hz or 60Hz.
	CALL	AYFXPLAYER._FRAME			; (1-9 scanlines)

	LD		IX,_GENERATE_VSYNC			; Set the display routine pointer to generate the VSync pulse next.
	JP		$02A4						; Return to the user program.

	; end bottom border


	.align	32
_screen:
	.incbin	hrmonk.bin

.endmodule