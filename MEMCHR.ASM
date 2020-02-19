.model	tiny
.code
locals	@@
org	100h

start:
	mov	di, offset data
	mov	cx, 05h
	mov	al, 00h

	call	memchr

	mov	ax, 4C00h
	int	21h

data:	db 0Fh, 0Eh, 0Ch, 0Bh, 0Ah
;========
; Inputs: 	DI - memory address
;		CX - length
;		AL - byte to find
; Outputs:	DI - adress of first equal byte 
;		or DI + CX if there is no such byte
; Destructs:	DI, CX, AL, ES
;========
memchr	proc
	cld
	mov	ax, ds
	mov	es, ax
	repne 	scasb
	jne	@@end
	sub	di, 1
@@end:	ret
memchr	endp

end start