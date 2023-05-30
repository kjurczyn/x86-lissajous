section .data
	width: dq 0
	height: dq 0
	corner_x: dq 0
	corner_y: dq 0
	a: dq 0
	b: dq 0
	point_list: dd 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
	c_x: dq 0
	c_y: dq 0
	p_x: dq 0
	p_y: dq 0

; //rcx, rdx, r8, r9, stack
section .text 
	global lissajous_draw
	extern custom_draw_spline
lissajous_draw:
; Prolog
; Moving args into memory
	mov rax, width
	mov [rax], rcx
	mov rax, height
	mov [rax], rdx
	mov rax, a
	mov[rax], r8
	mov rax, b
	mov [rax], r9
	



	push rbp
	mov rbp, rsp
; Main


	



	

; Epilog
	pop rbp
	ret

