;-------------------------------------------------------------------------------
;
.module	DISPLAY

; To install the display driver simply:
;	ld 	ix,DISPLAY._GENERATE

; Special thanks to:
;
; *******************************
; * ZX81 Lo-Res Display Drivers *
; *******************************
; (c)2022 Paul Farrow, www.fruitcake.plus.com
;
; You are free to use and modify these drivers in your own programs.

#define BOTTOM_BORDER_USER_ACTIONS

_GENERATE_VSYNC:
	IN		A,($FE)						; Start the VSync pulse.

	; The user actions must always take the same length of time.
	; Should be at least 3.3 scanlines (684 T-states) in duration for Chroma 81 compatibility.
	CALL	INPUT._read

	OUT		($FF),A						; End the VSync pulse.

	LD		HL,(frames)
	INC		HL
	LD		(frames),hl

.ifdef TOP_BORDER_USER_ACTIONS
	LD		A,(margin)					; Fetch or specify the number of lines in the top border (must be a multiple of 8).
	NEG									; The value could be precalculated to avoid the need for the NEG and INC A here.
	INC		A
	EX		AF,AF'

	OUT		($FE),A						; Turn on the NMI generator to commence generating the top border lines.

	;		OUT	($FD),A					; @ Turn off the NMI generator to visually see how long the user actions take, i.e. how many extra top border lines it introduces.
	CALL	DO_TOP_USER_ACTIONS			; The user actions must not take longer than the time to generate the top border at either 50Hz or 60Hz.
	;		OUT	($FE),A					; @ Turn on the NMI generator to stop timing the user actions.

	LD		IX,_GENERATE			; Set the display routine pointer to generate the main picture area next.
	JP		$02A4						; Return to the user program.

.else

	LD		A,(margin)					; Fetch or specify the number of lines in the top border (must be a multiple of 8).
	LD		IX,_GENERATE				; Set the display routine pointer to generate the main picture area next.
	JP		$029E						; Commence generating the top border lines and return to the user program.

.endif

_GENERATE:
	LD		A,R							; Fine tune delay.

	LD		BC,$1901					; B=Row count (24 in main display + 1 for the border). C=Scan line counter for the border 'row'.
	LD		A,$F5						; Timing constant to complete the current border line.
	CALL	$02B5						; Complete the current border line and then generate the main display area.

.ifdef BOTTOM_BORDER_USER_ACTIONS

	LD		A,(margin)					; Fetch or specify the number of lines in the bottom border (does not have to be a multiple of 8).
	NEG									; The value could be precalculated to avoid the need for the NEG and INC A here.
	INC		A
	EX		AF,AF'

	OUT		($FE),A						; Turn on the NMI generator to commence generating the bottom border lines.

	; The user actions must not take longer than the time to generate the bottom border at either 50Hz or 60Hz.
	CALL	AYFXPLAYER._FRAME			; (1-9 scanlines)

	LD		IX,_GENERATE_VSYNC			; Set the display routine pointer to generate the VSync pulse next.
	JP		$02A4						; Return to the user program.

.else

	LD		A,(margin)					; Fetch or specify the number of lines in the bottom border (does not have to be a multiple of 8).
	LD		IX,_GENERATE_VSYNC			; Set the display routine pointer to generate the VSync pulse next.
	JP		$029E						; Commence generating the bottom border lines and return to the user program.

.endif


.endmodule