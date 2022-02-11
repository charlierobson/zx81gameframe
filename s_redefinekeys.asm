;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module REDEFINE


_run:
	ld		hl,_pkf					; install 'press key for:' text
	ld		de,dfile+1
	ld		bc,32
	ldir

	xor		a						; clear key line
	ld		hl,dfile+1+33
	ld		de,dfile+1+34
	ld		(hl),a
	ld		bc,31
	ldir

	ld		hl,INPUT._gameinput+1
	ld		(_keyaddress),hl

	ld		hl,dfile+1+3*33
	ld		(_screenaddress),hl

	ld		hl,_upk					; these need to be in same order as inputs in table, u,d,l etc.
	ld		(_nameaddress),hl

	call	_redeffit
	call	_redeffit
	call	_redeffit
	call	_redeffit
	call	_redeffit

	ld		hl,(INPUT._fire-2)		; copy fire button definition to title screen input states
	ld		(INPUT._begin-2),hl

	ld		b,50

-:	call	framesync
	djnz	{-}

	ret



_redeffit:
	ld		hl,(_nameaddress)
	ld		de,dfile+16				; copy key text to screen
	ld		bc,5
	ldir

_loop:
	call	framesync
	call	_getcolbit
	cp		$ff
	jr		z,_loop

	xor		$ff						; flip bits to create column mask
	ld		c,a						; column mask in c, port num in b from getcolbit

	ld		hl,INPUT._gameinput+1
	ld		de,(_keyaddress)

_testnext:
	and		a
	sbc		hl,de					; done when we are about to check the current input state
	jr		z,_oktogo

	add		hl,de					; otherwise check to see if port/mask combo is already used
	ld		a,(hl)
	inc		hl
	cp		b
	jr		nz,_nomatchport

	ld		a,(hl)
	cp		c
	jr		nz,_nomatchport

	ld		b,4						; combo already used, warn user
-:  call    framesync
	ld		e,b
	call	invertscreen
	ld		b,e
	djnz	{-}

	call	_waitnokey
	jr		_loop

_nomatchport:
	inc		hl
	inc		hl
	inc		hl
	jr		_testnext

_oktogo:
	ld		hl,(_keyaddress)					; store the redefined key data back into the input structure
	ld		(hl),b
	inc		hl
	ld		(hl),c

	ld		hl,(_nameaddress)					; zero out the key name part of the name string, "fire  space" -> "fire       " 
	ld		de,6
	add		hl,de
	push	hl
	pop		de
	push	de
	ld		bc,4
	ld		(hl),0
	inc		de
	ldir

	ld		hl,(_keyaddress)					; get pointer to HBT string of key name
	call	INPUT._getkeynameptr

	pop		de									; -> name string + 6

-:	ld		a,(hl)								; write the key name into the key string
	inc		hl
	ld		b,a
	res		7,a
	ld		(de),a
	inc		de
	bit		7,b
	jr		z,{-}

	ld		hl,(_nameaddress)					; copy name to screen
	ld		de,(_screenaddress)
	ld		bc,11
	ldir

	ld		(_nameaddress),hl					; -> next name string
	ld		hl,33-11
	add		hl,de
	ld		(_screenaddress),hl					; -> next screen line

	ld		hl,(_keyaddress)
	ld		de,4
	add		hl,de
	ld		(_keyaddress),hl

_waitnokey:
	call	framesync
	call	_getcolbit
	cp		$ff
	jr		nz,_waitnokey
	ret


_getcolbit:
	ld		bc,$fefe

-:	in		a,(c)					; byte will have a 0 bit if a key is pressed
	or		$e0
	cp		$ff
	ret		nz

	rlc		b						; rotate row selection bit through B & carry
	jr		c,{-}					; carry clear when we've done the once around
	ret


_keyaddress:
	.word	0

_screenaddress:
	.word	0

_nameaddress:
	.word	0

_pkf:
			;--------========--------========
	.asc	"press key for:                  "
_upk:
	.asc	"up    q    "
_dnk:
	.asc	"down  a    "
_lfk:
	.asc	"left  o    "
_rtk:
	.asc	"right p    "
_frk:
	.asc	"fire  space"

.endmodule
