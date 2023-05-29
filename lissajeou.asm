section .data
	width: dq 0
	height: dq 0
	pixel_array_address: dq 0
	a: dq 0
	b: dq 0
	c_x: dq 0
	c_y: dq 0
	p_x: dq 0
	p_y: dq 0

; //rcx, rdx, r8, r9, stack
section .text 
	global lissajous_draw
lissajous_draw:
; Prolog
; Moving args into memory
	mov rax, pixel_array_address
	mov [rax], rcx
	mov rax, width
	mov [rax], rdx
	mov rax, height
	mov [rax], r8
	mov rax, a
	mov [rax], r9
	mov rax, b
	pop rbx
	mov [rax], rbx



	push rbp
	mov rbp, rsp
; Main


	



	

; Epilog
	pop rbp
	ret
; DrawLine
draw_line:
; 	dx = x2 − x1
; 	dy = y2 − y1
; 	for x from x1 to x2 do
;     	y = y1 + dy × (x − x1) / dx
;     	plot(x, y)
;
; 	rcx = x1, rdx = y1, r8 = x2, r9 = y2
	mov r10, rcx ; r10 = x1
	mov r11, r8	 ; r11 = x2
	sub r11, r10 ; r11 = x2-x1
	mov r12, rdx ; r12 = y1
	mov r13, r9	 ; r13 = y2
	sub r13, r12 ; r13 = y2-y1
draw_line_loop:
	; r10 = current x
	; r9 = y
	; r12 = x - x1
	; sub r12, r11 = r12 - r11
	mov r9, rdx ; r9 = y1
	mov r12, r10 ; r12 = x
	sub r12, rcx ; r12 = x - x1
	imul r12, r13 ; r12 = dy * (x-x1)
	mov rax, r12
	push rdx
	xor rdx, rdx
	idiv r11 ; rax = dy * (x-x1) / dx
	pop rdx
	add r9, rax ; r9 = y1 + dy × (x − x1) / dx

;Plotting (x, y) = (r10, r9)
	

	ret

