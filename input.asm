;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module INPUT


_settitle:
	ld		hl,_titleinput
	jr		{+}

_setgame:
	ld		hl,_gameinput
+:
	ld		(_inputptr),hl
	ret


_read:
	ld		bc,$e007				; initiate a zxpand joystick read
	ld		a,$a0
	out		(c),a

_inputptr=$+1
	ld		hl,_titleinput     		; self modified
	nop								; timing

	in		a,(c)
	ld		(_jsval),a						; cache joystick read value in e

	ld		c,$fe					; keyboard input port
	ld		de,0						; 

	; point at first input state block,
	; return from update function pointing to next
	;
	call	_update ; (up)
	call	_update ; (down)
	call	_update ;  etc.
	call	_update ;

	; fall into here for last input

_update:
_jsval=$+1
	ld		a,0						; !! self modifies - js value
	and		(hl)					; and with js mask, 0 if dirn pressed
	sub		1						; carry set if result was 0. DEC doesnt affect carry :(
	rl		e						; js result: 1 if dirn detected
	inc		hl						; -> kb port address
	ld		b,(hl)
	in		a,(c)					; get key input bits
	inc		hl						; -> key row mask
	and		(hl)					; result will be 0 if key pressed
	sub		1						; carry set if result was 0
	rla								; carry into bit 0
	or		e						; integrate js results into bit 0
	rra								; bit 0 back into carry
	inc		hl						; ->key state
	rl		(hl)					; shift carry into input bit train
	inc		hl						; -> next input in table
	ret


;	-input port- 			-bit-
;							4  3  2  1  0

;	$FE %11111110			V, C, X, Z, SH	
;	$FD %11111101			G, F, D, S, A	
;	$FB %11111011			T, R, E, W, Q	
;	$F7 %11110111			5, 4, 3, 2, 1	
;	$EF %11101111			6, 7, 8, 9, 0	
;	$DF %11011111			Y, U, I, O, P	
;	$BF %10111111			H, J, K, L, NL	
;	$7F %01111111			B, N, M, ., SP	
;
; input state data:
;
; joystick bit, or $ff/%11111111 for no joy
; key row input port address,
; key mask, or $ff/%11111111 for no key
; output trigger impulse

_titleinput:
	.byte	%00001000,$7F,%00000001,0		; startgame	    (SP)
	.byte	%11111111,$FB,%00001000,0		; redefine	    (R)
	.byte	%11111111,$DF,%00000100,0		; instructions  (I)
	.byte	%11111111,$FE,%11111111,0
	.byte	%11111111,$FE,%11111111,0

_gameinput:
	.byte	%10000000,$FB,%00000001,0		; up    (Q)
	.byte	%01000000,$FD,%00000001,0		; down	(A)
	.byte	%00100000,$DF,%00000010,0		; left	(O)
	.byte	%00010000,$DF,%00000001,0		; right	(P)
	.byte	%00001000,$7F,%00000001,0		; fire	(SP)


; calculate actual input impulse addresses
;
_begin	= _titleinput + 3
_redef	= _titleinput + 7
_instr	= _titleinput + 11

_up		= _gameinput + 3
_down	= _gameinput + 7
_left	= _gameinput + 11
_right	= _gameinput + 15
_fire	= _gameinput + 19

.endmodule
