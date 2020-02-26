.model	tiny
.code
org	100h

.code

start:
	mov	di, offset string
	
	call	strlen

	mov	ax, 4C00h
	int	21h

string:	db	'12345', 0h

MAXLEN	equ	00FFFFh
;========
; Inputs:	DS:DI - address of string
; Outputs:	CX - length of string
; Destructs:	AL, DI, CX
;========
strlen	proc
	cld

	xor	al, al		; al = 0
	mov	cx, MAXLEN	; cx = MAXLEN

	repne	scasb		; while (*(di++) != 0);

	xor	cx, MAXLEN
	dec	cx		; cx = len

	ret
strlen	endp

end	start
