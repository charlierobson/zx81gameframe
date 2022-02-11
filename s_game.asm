;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module GAME

_run:
	call	INPUT._setgame

	ld		hl,_text
	ld		de,dfile+1
	ld		bc,_textend-_text
	ldir

_loop:
	call	framesync

	ld		a,(INPUT._up)
	ld		de,dfile+1+4*33
	call 	_binout

	ld		a,(INPUT._down)
	ld		de,dfile+1+5*33
	call 	_binout

	ld		a,(INPUT._left)
	ld		de,dfile+1+6*33
	call 	_binout

	ld		a,(INPUT._right)
	ld		de,dfile+1+7*33
	call 	_binout

	ld		a,(INPUT._fire)
	and		3
	cp		1
	jr		nz,_loop

	ret


_binout:
	ld		b,8

-:	rlca
	push	af
	and		1
	add		a,$1c
	ld		(de),a
	pop		af
	inc		de
	djnz	{-}
	ret


_text:
			;--------========--------========
	.asc	"game.        press fire to lose."
_textend:

.endmodule
