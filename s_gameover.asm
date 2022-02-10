;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module GAMEOVER

_run:
	call	INPUT._settitle
	call	clearscreen

	ld		hl,_text
	ld		de,dfile+1
	ld		bc,_textend-_text
	ldir

	ld		b,100

-:	call	framesync
	djnz	{-}

	ret


_text:
			;--------========--------========
	.asc	"game over.                      "
_textend:

.endmodule
