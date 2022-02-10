;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module INSTRUCTIONS

_run:
	ld		hl,_text
	ld		de,dfile+1
	ld		bc,_textend-_text
	ldir

_loop:
	call	framesync
	call	INPUT._read

	ld		a,(INPUT._begin)
	and		3
	cp		1
	jr		nz,_loop

	ret


_text:
			;--------========--------========
	.asc	"instructions screen. press fire."
_textend:

.endmodule
