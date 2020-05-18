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
; Corrupts:	DI
;========
strchr	proc
	cld
@@loop:
	cmp	byte ptr ds:[di], 00h
	je	@@end			; if (!*di) break;
	scasb				
	jne	@@loop			; if (*(di++) == al) break;
@@found:
	dec	di			; di--
@@end:
	ret
strchr	endp

end	start
