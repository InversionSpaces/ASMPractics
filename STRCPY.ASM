.model	tiny
.code
org	100h

locals	@@

start:
	mov	ax, 4C00h
	int	21h

;========
; Inputs:	ES:DI - address of destination string
;		DS:SI - address of source string
; Outputs:	Source string copied to destination string
; Destructs:	DI, SI
;========
strcpy	proc
	cld
@@loop:
	cmp	byte ptr ds:[si], 00h
	je	@@end
	movsb
	jmp	@@loop
@@end:
	mov	byte ptr es:[di], 00h
	ret
strcpy	endp
	
end	start
