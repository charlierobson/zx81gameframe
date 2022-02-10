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
	call	INPUT._read

	ld		a,(INPUT._fire)
	and		3
	cp		1
	jr		nz,_loop

	ret


_text:
			;--------========--------========
	.asc	"game.        press fire to lose."
_textend:

.endmodule
