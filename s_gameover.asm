;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module GAMEOVER

_run:
	call	INPUT._settitle

	ld		hl,_text
	ld		de,dfile+1
	ld		bc,_textend-_text
	ldir

	ld		b,100

_loop:
	call	framesync
	djnz	_loop

	ret


_text:
			;--------========--------========
	.asc	"game over.                      "
_textend:
