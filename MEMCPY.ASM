.model	tiny
.code
org	100h

start:
	mov	ah, 09h	
	mov	dx, offset one
	int	21h
	
	mov	si, offset two
	mov	di, offset one
	mov	ax, ds
	mov	es, ax
	mov	cx, 04h
	
	call	memcpy

	mov	ah, 09h
	mov	dx, offset one
	int	21h

	mov	ax, 4C00h
	int	21h

one:	db 'one$'
two:	db 'two$'

;========
; Inputs:	DS:SI - source address
;		ES:DI - destination address
;		CX - length
; Outputs:	Nothing
; Destructs:	DI, SI, CX, AX
;========
memcpy	proc
	cld
	mov	ax, ds
	mov	ex, ax
	rep	movsb
	ret
memcpy	endp

end	start