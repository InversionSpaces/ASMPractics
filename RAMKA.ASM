.286
.model	tiny
.386
.code
org	100h

locals	@@

ARGST	equ	80h
VIDSEG	equ	0b800h

BGCODE	equ	0070h
SHCODE	equ	0058h

SPACE	equ	0020h
HEDGE	equ	00cdh
VEDGE	equ	00bah
LTCOR	equ	00c9h
RTCOR	equ	00bbh
LBCOR	equ	00c8h
RBCOR	equ	00bch

STARTX	equ	3
STARTY	equ	3

SIZEX	equ	20
SIZEY	equ	8	

;TICKS	equ	5

start:	
	mov	si, offset ARGS
	mov	bx, S_ARGS

	call	READARGS	
	
	mov	al, byte ptr [ARGS]
	call	PRINTNUM

	mov	al, byte ptr [ARGS + 1]
	call	PRINTNUM

	mov	al, byte ptr [ARGS + 2]
	call	PRINTNUM

	mov	al, byte ptr [ARGS + 3]
	call	PRINTNUM

	mov	bl, byte ptr [ARGS]
	mov	bh, byte ptr [ARGS + 1]
	mov	dl, byte ptr [ARGS + 2]
	mov	dh, byte ptr [ARGS + 3]

	CALL	ANIM_TABLE
	
	mov	ax, 4C00h
	int	21h		; exit(0)

ARGS	DB	4 DUP(?)
S_ARGS	equ	$ - ARGS


PRINTNUM	PROC
@@loop:
	xor	ah, ah	

	mov	bl, 0Ah
	div	bl

	mov	dl, ah
	add	dl, '0'

	mov	bl, al

	mov	ah, 02h	
	int	21h

	mov	al, bl
	
	cmp	al, 00h
	jne	@@loop

	mov	dl, 0Ah
	mov	ah, 02h
	int 	21h

	mov	dl, 0Dh
	mov	ah, 02h
	int	21h

	ret		
PRINTNUM	ENDP

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

;=======================
; Inputs:	AL - first number
;		AH - second number
; Outputs:	CL - max of numbers
; Destructs:	CL
;=======================
MAX	PROC
	cmp	ah, al
	jg	@@greater
	
	mov	cl, al
	ret
@@greater:
	mov	cl, ah
	ret	
MAX	ENDP


;=======================
; Inputs: 	BL - x coord
;		BH - y coord
;		DL - sizex
;		DH - sizey
; Outputs:	Animate table
; Destructs:	AX, BX, CX, DX, DI, ES
;=======================
ANIM_TABLE	PROC
	mov	ax, dx		; ax = dx
	sub	ah, 02h         ; ah -= 2
	sub	al, 02h		; al -= 2
	xor	cx, cx		; cx = 0

	call	MAX		; cx = max(sizex - 2, sizey - 2)
	inc	cx		; cx++ (for cx == 0)
@@loop:
        cmp	cl, al
        jl	@@lsizex

        mov	dl, 02h
        jmp	@@sizex
@@lsizex:
        mov	dl, al
        sub	dl, cl
        add	dl, 02h		
        
@@sizex:			; dl = max(2, sizex - cx)
	
	cmp	cl, ah
	jl	@@lsizey
	           
	mov	dh, 02h
	jmp	@@sizey
@@lsizey:
	mov	dh, ah
	sub	dh, cl
	add	dh, 02h
@@sizey:			; dh = max(2, sizey - cx)
	
	push	ax
	push	bx
	push	cx

	call	DRAW_TABLE

	mov	ah, 86h
	mov	dx, 5FFFh
	xor	cx, cx

	int	15h

	pop	cx
	pop	bx
	pop	ax

	loop	@@loop
	ret
ANIM_TABLE	ENDP

;------------------------------
; Inputs:	bl - x, bh - y
; Destroys:	ax, bx, dx
; Outputs:	di - offset
;------------------------------
.countoffset	macro
	xor	ax, ax		; ax = 0
	
	mov	al, 50h		; ax = 80
	mul	bh		; ax = 80 * y
	
	add	al, bl		
	adc	ah, 0		; ax = 80 * y + x
	
	mov	bx, ax	
	mov	ax, 02h	
	mul	bx		; dx:ax = (80 * x + y) * 2

	mov	di, ax		; di = ax	
		endm

;=========================
; Inputs:	BL - x coord 
;		BH - y coord
;		DL - sizex 
;		DH - sizey
; Outputs:	Draw table
; Destructs:    AX, BX, CX, DX, DI, ES
;=========================
DRAW_TABLE	PROC
	mov	cx, VIDSEG
	mov	es, cx		; es = VIDSEG
	
	mov	cx, bx		; save bx in cx

	; LTCOR {
	push	dx		; save dx
	.countoffset
	pop	dx		; restore dx

	mov	ax, (BGCODE shl 8) or LTCOR	
	mov	word ptr es:[di], ax
	; }

	mov	bx, cx		; restore bx

; TOPBAR {
	add	di, 02h		; di += 2
	
	xor	cx, cx		; cx = 0
	add	cl, dl		; cx = sizex
	sub	cl, 02h		; cx = sizex - 2

	mov	ax, (BGCODE shl 8) or HEDGE
	rep	stosw
; }

	; RTCOR {
	mov	ax, (BGCODE shl 8) or RTCOR
	mov	word ptr es:[di], ax	
	; }

	mov	cx, bx		; save bx in cx

	; LBCOR {
	add	bh, dh
	dec	bh		; bh = y + sizey - 1

	push	dx		; save dx
	.countoffset
	pop	dx		; restore dx

	mov	ax, (BGCODE shl 8) or LBCOR
	mov	word ptr es:[di], ax
	; }

	mov	bx, cx		; resotre bx

	; BOTBAR {
	add	di, 02h		; di += 2

	xor	cx, cx		; cx = 0
	add	cl, dl		; cx = sizex
	sub	cx, 02h		; cx = sizex - 2

	mov	ax, (BGCODE shl 8) or HEDGE
	rep	stosw
	; }

	; RBCOR {
	mov	ax, (BGCODE shl 8) or RBCOR
	mov	word ptr es:[di], ax
	; }

	; RSHADOW {
	mov	ax, (SHCODE shl 8) or SPACE
	mov	word ptr es:[di + 2], ax
	; }

	xor	cx, cx		; cx = 0
	add	cl, dh		; cx = sizey
	sub	cx, 2		; cx = sizey - 2

	cmp	cx, 00h
	je	@@end
@@fill:
	inc	bh		; y++

	push	bx		; save bx
	push	dx		; save dx
	push	cx		; save cx

	xor	cx, cx		; cx = 0
	mov	cl, dl		; cx = sizex
	sub	cx, 02h		; cx = sizex - 2

	; LEDGE {
	.countoffset
	mov	ax, (BGCODE shl 8) or VEDGE
	mov	word ptr es:[di], ax
	; }	

	; FILL {
	add	di, 02h
	mov	ax, (BGCODE shl 8) or SPACE
	rep	stosw
	; }

	; REDGE {
	mov	ax, (BGCODE shl 8) or VEDGE
	mov	word ptr es:[di], ax
	; }

	; RSHADOW {
	mov	ax, (SHCODE shl 8) or SPACE
	mov	word ptr es:[di + 2], ax
	; }	

	pop	cx		; restore cx
	pop	dx		; restore dx
	pop	bx		; restore bx
	
	loop	@@fill

@@end:
	add	bh, 02h		; y += 2
	inc	bl		; x++
	
	xor	cx, cx		; cx = 0
	add	cl, dl          ; cx = sizex

	.countoffset
	mov	ax, (SHCODE shl 8) or SPACE
	rep	stosw

	ret	
DRAW_TABLE	ENDP

end	start
