.286
.model tiny
.386
.code
org	100h

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

STARTX	equ	5
STARTY	equ	5

SIZEX	equ	20
SIZEY	equ	12	

TICKS	equ	6

start:	
	push	TICKS
	push	SIZEY
	push	SIZEX
	push	STARTY
	push	STARTX

	CALL	ANIM_TABLE 
	
	mov	ax, 4C00h
	int	21h		; exit(0)

ANIM_TABLE PROC ; (x, y, sizex, sizey, ticks)
	push	bp
	mov	bp, sp
	pusha

	mov	ax, word ptr [bp + 8]
	div	word ptr [bp + 12]

	mov	bx, ax			; bx = sizex / ticks

	mov	ax, word ptr [bp + 10]
	div	word ptr [bp + 12]	
	
	mov	dx, ax			; dx = sizey / ticks

	mov	cx, word ptr [bp + 12]	
	sub	cx, 2			; cx = ticks - 2

ANIM_TABLE_LOOP:
	mov	ax, word ptr [bp + 12]
	sub	ax, cx			; ax = ticks - cx
	mul	dx			; ax = (ticks - cx) * (sizey / ticks)
	push	ax			; push sizey

	mov	ax, word ptr [bp + 12]
	sub	ax, cx			; ax = ticks - cx
	mul	bx			; ax = (ticks - cx) * (sizex/ ticks)
	push	ax			; push sizex
	
	push	word ptr [bp + 6]	; push y
	push	word ptr [bp + 4]	; push x

	CALL	DRAW_TABLE

	loop	ANIM_TABLE_LOOP

	pop	bp
	popa
	
	ret	2 * 5
ANIM_TABLE ENDP

DRAW_TABLE PROC	; (x, y, sizex, sizey)
	push	bp
	mov	bp, sp
	pusha

	mov	ah, BGCODE
	
	; ==LTCOR==
	mov	al, LTCOR
	
	push	ax			; push symbol
	push	word ptr [bp + 6]	; push y
	push	word ptr [bp + 4]	; push x
	
	CALL	SET_SYMBOL
	
	; ==RTCOR==
	mov	al, RTCOR
	
	push	ax			; push symbol
	push	word ptr [bp + 6]	; push y

	mov	bx, word ptr [bp + 4]	; bx = x
	add	bx, word ptr [bp + 8]	; bx = x + sizex
	sub	bx, 1			; bx = x + sizex - 1
	push	bx			; push x

	CALL	SET_SYMBOL

	; ==LBCOR==
	mov	al, LBCOR
	
	push	ax			; push symbol

	mov	bx, word ptr [bp + 6]	; bx = y
	add	bx, word ptr [bp + 10]	; bx = y + sizey
	sub	bx, 1			; bx = y + sizey - 1
	push	bx			; push y

	push	word ptr [bp + 4]	; push x

	CALL	SET_SYMBOL

	; ==RBCOR==
	mov	al, RBCOR
	
	push	ax			; push symbol

	mov	bx, word ptr [bp + 6]	; bx = y
	add	bx, word ptr [bp + 10]	; bx = y + sizey
	sub	bx, 1			; bx = y + sizey - 1
	push	bx			; push y

	mov	bx, word ptr [bp + 4]	; bx = x
	add	bx, word ptr [bp + 8]	; bx = x + sizex
	sub	bx, 1			; bx = x + sizex - 1
	push	bx			; push x

	CALL	SET_SYMBOL

	; ==HEDGE== TOP
	mov	al, HEDGE
	
	push	ax			; push symbol

	mov	bx, word ptr [bp + 8]	; bx = sizex
	sub	bx, 2			; bx = sizex - 2
	push	bx			; push length
	
	push	word ptr [bp + 6]	; push y
	
	mov	cx, word ptr [bp + 4]	; cx = x
	inc	cx			; cx = x + 1
	push	cx			; push x

	CALL	DRAW_X

	; ==HEDGE== BOTTOM

	push	ax			; push symbol
	push	bx			; push length
	
	mov	dx, word ptr [bp + 6]	; dx = y
	add	dx, word ptr [bp + 10]	; dx = y + sizey
	sub	dx, 1			; dx = y + sizey - 1
	push	dx			; push y
	
	push	cx			; push x

	CALL	DRAW_X

	; ==VEDGE== LEFT
	mov	al, VEDGE
	
	push	ax			; push symbol

	mov	bx, word ptr [bp + 10]	; bx = sizey
	sub	bx, 2			; bx = sizey - 2
	push	bx			; push length
	
	mov	cx, word ptr [bp + 6]	; cx = y
	inc	cx			; cx = y + 1
	push	cx			; push y

	push	word ptr [bp + 4]	; push x

	CALL	DRAW_Y

	; ==VEDGE== RIGHT
	
	push	ax			; push symbol
	push	bx			; push length
	
	mov	cx, word ptr [bp + 6]	; cx = y
	inc	cx			; cx = y + 1
	push	cx			; push y

	mov	dx, word ptr [bp + 4]	; dx = x
	add	dx, word ptr [bp + 8]	; dx = x + sizex
	sub	dx, 1			; dx = x + sizex - 1
	push	dx			; push x

	CALL	DRAW_Y

	; ==SPACE==
	mov	al, SPACE

	mov	bx, word ptr [bp + 8]	; bx = sizex
	sub	bx, 2			; bx = sizex - 2
	
	mov	cx, word ptr [bp + 10]	; bx = sizey
	sub	cx, 2			; bx = sizey - 2
DRAW_TABLE_LOOP:
	push	ax			; push symbol
	push	bx			; push length
	
	mov	dx, word ptr [bp + 6]	; dx = y
	add	dx, cx			; dx = y + cx
	push	dx			; push y
	
	mov	dx, word ptr [bp + 4]	; dx = x
	inc 	dx			; dx = x + 1
	push	dx			; push x

	CALL	DRAW_X
	
	loop	DRAW_TABLE_LOOP

	; ==SHADOW== BOTTOM
	
	mov	ah, SHCODE

	push	ax			; push symbol
	push	word ptr [bp + 8]	; push length

	mov	bx, word ptr [bp + 6]	; bx = y
	add	bx, word ptr [bp + 10]	; bx = y + sizey
	push	bx			; push y
	
	mov	bx, word ptr [bp + 4]	; bx = x
	inc	bx			; bx = x + 1
	push	bx			; push x

	CALL	DRAW_X	

	; ==SHADOW== RIGHT
	push	ax			; push symbol

	mov	bx, word ptr [bp + 10]	; bx = sizey
	sub	bx, 1			; bx = sizey - 1
	push	bx			; push length

	mov	bx, word ptr [bp + 6]	; bx = y
	inc	bx			; bx = y + 1
	push	bx			; push y
	
	mov	bx, word ptr [bp + 4]	; bx = x
	add	bx, word ptr [bp + 8]	; bx = x + size
	push	bx			; push x

	CALL	DRAW_Y	

	popa
	pop	bp

	ret	2 * 4
DRAW_TABLE ENDP

DRAW_X PROC	; (x, y, length, symbol)
	push	bp
	mov	bp, sp
	pusha

	mov	bx, [bp + 4]	; bx = x coord
	mov	cx, [bp + 8]	; cx = length

DRAW_X_LOOP:
	push	word ptr [bp + 10]	; push symbol code
	push	word ptr [bp + 6]	; push y coord

	mov	ax, bx
	add	ax, cx
	sub	ax, 1			; ax = bx + cx - 1

	push	ax			; push x coord
	
	call SET_SYMBOL

	loop	DRAW_X_LOOP

	popa
	pop	bp

	ret	2 * 4
DRAW_X	ENDP

DRAW_Y PROC	; (x, y, length, symbol)
	push	bp
	mov	bp, sp
	pusha

	mov	bx, [bp + 6]		; bx = y coord
	mov	cx, [bp + 8]		; cx = length

DRAW_Y_LOOP:
	push	word ptr [bp + 10]	; push symbol code

	mov	ax, bx
	add	ax, cx
	sub	ax, 1			; ax = bx + cx - 1

	push	ax			; push y coord
	
	push	word ptr [bp + 4]	; push x coord
	
	call SET_SYMBOL

	loop	DRAW_Y_LOOP

	popa
	pop	bp

	ret	2 * 4
DRAW_Y	ENDP

SET_SYMBOL PROC	; (x, y, symbol) 
	push	bp		; save bp register
	mov	bp, sp		; get stack pointer
	pusha			; save all registers

	mov	ax, [bp + 6]	; ax = y coord

	mov	bx, 50h
	mul	bx		; ax = 80 * y

	mov	bx, [bp + 4]	; bx = x coord

	add	ax, bx		; ax = 80 * y + x

	mov	bx, 02h
	mul	bx		; ax = (80 * y + x) * 2

	mov	bx, ax
	mov	ax, [bp + 8]	; ax = symbol code

	push	VIDSEG
	pop	es

	mov	word ptr es:[bx], ax
	
	popa			; restore registers
	pop	bp		; restore bp
	ret	2 * 3		; return with 3 args

SET_SYMBOL ENDP

end	start
