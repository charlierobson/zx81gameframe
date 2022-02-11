;-------------------------------------------------------------------------------
;
.module A_MAIN

	.org	$4009

	.exportmode NO$GMB
	.export

	.include	charmap.asm

versn	.byte	$00
e_ppc	.word	$0000
d_file	.word	dfile
df_cc	.word	dfile+1 
vars	.word	_var
dest	.word	$0000 
e_line	.word	_var+1 
ch_add	.word	_last-1 
x_ptr	.word	$0000 
stkbot	.word	_last 
stkend	.word	_last 
breg	.byte	$00 
mem		.word	membot 
unuseb	.byte	$00 
df_sz	.byte	$02 
s_top	.word	$0000 
last_k	.word	$ffff 
db_st	.byte	$ff
margin	.byte	55 
nxtlin	.word	_line10 
oldpc	.word	$0000
flagx	.byte	$00
strlen	.word	$0000 
t_addr	.word	$0c6b
seed	.word	$0000 
frames	.word	$ffff
coords	.byte	$00 
		.byte	$00 
pr_cc	.byte	188 
s_posn	.byte	33 
s_psn1	.byte	24 
cdflag	.byte	64 
prtbuff	.fill	32,0
prbend	.byte	$76
membot	.fill	32,0


;-------------------------------------------------------------------------------


_line1:
	.byte	0,1
	.word	_line1end-$-2
	.byte	$ea

	; enable our custom display handler. runs input processing in the vertical
	; sync and enables use of IY register.
	ld 		ix,DISPLAY._GENERATE

	; this is a typical game program cycle.

-:	call	TITLE._run
	call	GAME._run
    call    GAMEOVER._run
    jr      {-}


;-------------------------------------------------------------------------------


	.include s_title.asm
	.include s_instructions.asm
	.include s_redefinekeys.asm
	.include s_game.asm
	.include s_gameover.asm

	.include general.asm
	.include input.asm
	.include displaydriver.asm


dfile:
	.repeat 24
	  .byte $76
	  .fill 32,0
	.loop
	.byte   $76


;-------------------------------------------------------------------------------

.module A_MAIN

	.byte	$76
_line1end:
_line10:
	.byte	0,2
	.word	_line10end-$-2
	.byte	$F9,$D4,$C5,$0B				; RAND USR VAL "
	.byte	$1D,$22,$21,$1D,$20	; 16514 
	.byte	$0B							; "
	.byte	076H						; N/L
_line10end:

_var:
	.byte	080H
_last:

.endmodule
	.end
