;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module INSTRUCTIONS

_run:
	ld		hl,_text
	ld		de,dfile+1
	ld		bc,_textend-_text
	ldir

	ld		b,5									; display key config on screen. 5 keys
	ld		hl,REDEFINE._upk
	ld		de,dfile+1+3*33

-:	push	bc

	ld		bc,11
	ldir
	push	hl
	ld		hl,33-11
	add		hl,de
	push	hl
	pop		de
	pop		hl

	pop		bc
	djnz	{-}

_loop:
	call	framesync

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
