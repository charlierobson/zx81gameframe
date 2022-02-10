;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module TITLE

_run:
	call	INPUT._settitle

	ld		hl,0
	ld		(frames),hl

_redraw:

_loop:
	call	framesync
	call	INPUT._read

	ld		a,(frames)	; AB------
	rlca				; -------A
	rlca				; ------AB
	rlca				; -----AB-
	and		6			; 00000AB0  :- 0,2,4,6

	ld		hl,_titletextlist
	call	tableget

	ld		de,dfile+1
	ld		bc,32
	ldir

_nochangetext:
	ld		a,(frames)
	and		16
	jr		nz,_noflash

	ld		hl,dfile+1
	ld		b,32

-:	set		7,(hl)
	inc		hl
	djnz	{-}

_noflash:
	ld		a,(INPUT._redef)
	and		%00000011				; check for key just released
	cp		%00000010
	jr		nz,{+}

	call	REDEFINE._run
	jr		_redraw

+:
	ld		a,(INPUT._instr)
	and		%00000011
	cp		%00000010
	jr		nz,{+}

	call	INSTRUCTIONS._run
	jr		_redraw

+:	ld		a,(INPUT._begin)
	and		3
	cp		1
	jr		nz,_loop

	ret


_titletextlist:
	.word	_t1,_t2,_t3,_t2

			;--------========--------========
_t1	.asc	"      i for instructions        "
_t2	.asc	"         fire to start          "
_t3	.asc	"      r to redefine keys        "
