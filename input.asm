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
	ld		e,a						; cache joystick read value in e

	ld		c,$fe					; keyboard input port

	; point at first input state block,
	; return from update function pointing to next
	;
	call	_update ; (up)
	call	_update ; (down)
	call	_update ;  etc.
	call	_update ;

	; fall into here for last input

_update:
	ld		a,(hl)					; joystick mask
	ld		(_jstest),a				; self modify mask for j/s bit test

	inc		hl						; kb port address
	ld		b,(hl)
	in		a,(c)					; get key input bits
	inc		hl						; key row mask
	and		(hl)					; result will be a = 0 if required key is down
	jr		z,{+}					; skip joystick read if key detected

	ld		a,e						; retrieve cached js read

_jstest = $+1
+:	and		0						; self modified - result is 0 if key detected _or_ js & mask == 0
	sub		1						; carry set if result was 0 ie direction detected, DEC doesnt affect carry :(
	inc		hl						; key state
	rl		(hl)					; shift carry into bit train
	inc		hl						; leave hl ready for next input in table
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
