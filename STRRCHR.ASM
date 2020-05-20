.model	tiny
.code
org	100h

locals	@@

start:
	mov	ax, 4C00h
	int	21h

;========
; Inputs:	DS:DI - adress of null-terminated string
;		AL - char to find
; Outputs:	SI - adress of most right such char in string
;		or adress of null byte if there is no such symbol
; Destructs:	DI, SI, AX
;========
strrchr	proc
	cld
	xor	si, si			; si = 0
@@loop:
	mov	ah, byte ptr ds:[di]
	cmp	ah, 00h	
	je	@@check			; if (!*di) break;
	
	cmp	ah, al
	inc 	di
	jne	@@loop			; if (*di != al) continue

	mov	si, di
	dec	si			; si = di - 1
	
	jmp	@@loop
@@check:
	cmp	si, 00h
	jne	@@end
	mov	si, di
@@end:
	ret
strrchr	endp

end	start
