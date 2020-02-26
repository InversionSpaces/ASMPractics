.model	tiny
.code
org	100h

locals	@@

start:
	mov	ax, 4C00h
	int	21h

;========
; Inputs:	ES:DI - address of first string
;		DS:SI - address of second string
; Outputs:	FLAGS - result of CMP of first null byte in one string and
;		corresponding char in second string
; Destructs:	DI, SI
;========
strcmp	proc
@@loop:
	cmpsb
	jne	@@end

	cmp	byte ptr es:[di - 1], 00h
	je	@@nulldi

	cmp	byte ptr ds:[si - 1], 00h
	je	@@nullsi

	jmp	@@loop
@nulldi:
	cmp	byte ptr ds:[si - 1], 00h
	ret
@nullsi:
	cmp	00h, byte ptr es[di - 1]
	ret
@@end:
	ret
strcmp	endp

end	start