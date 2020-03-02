.model	tiny
.code
org	100h

locals	@@

ARGST	equ	80h

start:
	mov	si, offset ARGS
	mov	bx, A_SIZE
	
	call	READARGS

	mov	ax, 4C00h
	int	21h

ARGS	DB	4 DUP(?)
A_SIZE	equ	$ - ARGS

;================================
; Inputs: 	SI - adress of array of bytes
;		BX - size of array
; Outputs:	parsed numbers from command line in array
; Destroys:	AX, BX, CX, DX, DI, SI
;================================
READARGS	PROC
	mov	di, ARGST		; di = ARGS BYTES START

	xor	ch, ch
	mov	cl, byte ptr [di]	; cx = ARGS BYTES COUNT

	cmp	cx, 00h
	je	@@end			; if (cx == 0) return

	inc	di			; di++

@@args_loop:
	; If readed all args - end
	cmp	bx, 00h
	je	@@end

	; find non space symbol
	mov	al, ' '
	repe	scasb

	; if finded symbol is space - return
	cmp	byte ptr [di - 1], ' '
	je	@@end

	xor	ax, ax
	xor	dx, dx

@@num_loop:
	; CONVERT DIGIT {	
	mov	dl, 0Ah
	mul	dl			; ax *= 10
	
	mov	dl, byte ptr [di - 1]
	sub	dl, '0'			; dl = [di] - '0'

	add	al, dl
	adc	ah, 00h			; ax += dl
	; } CONVERT DIGIT
	
	; If its last symbol, write and return
	cmp	cx, 00h
	je	@@write_end

	dec	cx
	inc	di
	
	; If next symbol is not space - continue
	cmp	byte ptr [di - 1], ' '
	jne	@@num_loop
	
	; OUTPUT {
	mov	byte ptr [si], al

	inc	si
	dec	bx
	; } OUTPUT

	jmp	@@args_loop

@@write_end:
	mov	byte ptr [si], al
	dec	bx

@@end:
	ret

READARGS	ENDP

end	start