;-------------------------------------------------------------------------------
;
.module GENERAL

adda2hl:
	add		a,l
	ld		l,a
	ret		nc
	inc		h
	ret


tableget:
	call	adda2hl
	ld		a,(hl)
	inc		hl
	ld		h,(hl)
	ld		l,a
	ret


framesync:
	ld		hl,frames
	ld		a,(hl)
-:	cp		(hl)
	jr		z,{-}
	ret



invertscreen:
	ld		hl,dfile+1
	ld		c,24

--:	ld		b,32

-:	ld		a,(hl)
	xor		$80
	ld		(hl),a
	inc		hl
	djnz	{-}

	inc		hl
	dec		c
	jr		nz,{--}
	ret


seedrnd:
	ld		a,r
	ld		l,a
	ld		a,r
	ld		h,a
	ld		(_rndseed),hl
	ret


xrnd8:
	ld		a,(_rndseed)
	ld		c,a
	rrca
	rrca
	rrca
	xor		$1f
	add		a,c
	sbc		a,255
	ld		(_rndseed),a
	ret


xrnd16:
	ld		hl,(_rndseed)	    ; _rndseed must not be 0
	ld		a,h
	rra
	ld		a,l
	rra
	xor		h
	ld		h,a
	ld		a,l
	rra
	ld		a,h
	rra
	xor		l
	ld		l,a
	xor		h
	ld		h,a
	ld		(_rndseed),hl
	ret

_rndseed:
	.word	0
