.model	tiny
.code
org	100h
locals	@@

start:
	mov	al, 'G'
	mov	di, offset string

	call	strchr

	mov	ax, 4C00h
	int	21h

string:	db 'MEGA COOL STRING', 00h

;========
; Inputs:	DS:DI - address of null-terminated string
;		AL - char to find
; Outputs:	DI - address of first such byte in string or adress of null
;		if thre is no such byte
; Corrupts:	DI, AX
;========
strchr	proc
	cld
@@loop:
	mov	ah, byte ptr ds:[di]
	cmp	ah, 00h
	je	@@end			; if (!*di) break;
	cmp	ah, al
	inc	di
	jne	@@loop			; if (*(di++) == al) break;
	dec	di			; di--
@@end:
	ret
strchr	endp

end	start
