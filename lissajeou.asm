; The registers RAX, RCX, RDX, R8, R9, R10, R11 are considered volatile (caller-saved).[25]

; The registers RBX, RBP, RDI, RSI, RSP, R12, R13, R14, and R15 are considered nonvolatile (callee-saved).[25]

section .data
	center_x: dd 0.0
	center_y: dd 0.0
	a: dd 0.0
	b: dd 0.0
	point_list: dd 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
	temp: dq 0
	increment: dd 0.1
	w1: dd 0.0
	w2: dd 0.0
	d: dd 0.0
	pi_2: dd 0.0
	t: dd 0.0
; //rcx, rdx, r8, r9, stack
section .text 
	global lissajous_draw
	extern custom_draw_spline
lissajous_draw:
; Prolog
; Moving args into memory
;(const float a, const float b, const float x, const float y, const float w1, const float w2, const float d)
	push rbp
	mov rbp, rsp
	mov rax, a
	fstp dword [rax]
	mov rax, b
	fstp dword [rax]
	mov rax, center_x
	fstp dword [rax]
	mov rax, center_y
	fstp dword [rax]	
	mov eax, [rbp+8]
	mov r11, w1
	mov [r11], eax
	mov r11, w2
	mov eax, [rbp+12]
	mov [r11], eax
	mov eax, [rbp+16]
	mov r11, d
	mov [r11], eax




	
; Main
	fninit
	fldpi
	mov rax, temp
	mov dword [rax], 2
	fild dword [rax]
	fmulp ; multiply pi by 2, st0 = 2pi
	mov rax, pi_2
	fstp dword [rax] ;st0 = empty

; calculating first x
	mov rax, w1
	fld dword [rax] ;st0 = w
	mov rax, t
	fld dword [rax] ;st0 = t, st1 = w
	fmulp ; st0 = t*w 
	mov rax, d
	fld dword [rax] ;st0 = d, st1 = t*w
	faddp ;st0 = d + t*w
	fsin ;st0 = sin (d + t*w)
	mov rax, a
	fld dword [rax] ;st0 = a, st1 = sin (d + t*w)
	fmulp ; st0 = a * sin (d + t*w)
	mov rax, center_x
	fld dword [rax] ; st0 = center x, st1 =  a * sin (d + t*w)
	faddp ; st0 = center x + a * sin (d + t*w)
	mov rax, point_list+24
	fstp dword [rax] ; point_list[6] =  center x + a * sin (d + t*w), st0 = empty
; calculating first y
	mov rax, w2
	fld dword [rax] ; st0 = w2
	mov rax, t
	fld dword [rax] ;st0 = t
	fmulp ; st0 = w2*t
	fsin ; st0 = sin(w2*t)
	mov rax, b
	fld dword [rax] ;st0 = b, st1 = sin(w2*t)
	fmulp ; st0 = b*sin(t)
	mov rax, center_y
	fld dword [rax] ; st0 = center y, st1 = b*sin(w2*t)
	faddp ; st0 = center y + b*sin(t)
	mov rax, point_list+28
	fstp dword [rax] ; point_list[7] =  center y + b*sin(w2*t), st0 = empty


calculate_loop:
	fninit
	;moving last point from point list to the first place
	mov rax, point_list+24
	mov eax, [rax]
	mov rax, point_list
	mov [rax], eax
	mov rax, point_list+28
	mov eax, [rax]
	mov rax, point_list+4
	mov [rax], eax

; incrementing t 1
	mov rax, t
	fld dword [rax] ; st0 = t
	mov rax, increment
	fld dword [rax] ;st0 = increment
	faddp ; st0 = t + increment

	;calculate next x
	mov rax, w1
	fld dword [rax] ;st0 = w
	; mov rax, t
	; fld dword [rax] ;st0 = t, st1 = w
	fmulp ; st0 = t*w 
	mov rax, d
	fld dword [rax] ;st0 = d, st1 = t*w
	faddp ;st0 = d + t*w
	fsin ;st0 = sin (d + t*w)
	mov rax, a
	fld dword [rax] ;st0 = a, st1 = sin (d + t*w)
	fmulp ; st0 = a * sin (d + t*w)
	mov rax, center_x
	fld dword [rax] ; st0 = center x, st1 =  a * sin (d + t*w)
	faddp ; st0 = center x + a * sin (d + t*w)
	mov rax, point_list+8
	fstp dword [rax] ; point_list[0] =  center x + a * sin (d + t*w), st0 = empty
	; calculating next y
	mov rax, w2
	fld dword [rax] ; st0 = w2
	mov rax, t
	fld dword [rax] ;st0 = t
	fmulp ; st0 = w2*t
	fsin ; st0 = sin(w2*t)
	mov rax, b
	fld dword [rax] ;st0 = b, st1 = sin(w2*t)
	fmulp ; st0 = b*sin(t)
	mov rax, center_y
	fld dword [rax] ; st0 = center y, st1 = b*sin(w2*t)
	faddp ; st0 = center y + b*sin(t)
	mov rax, point_list+12
	fstp dword [rax] ; point_list[1] =  center y + b*sin(w2*t), st0 = empty

; incrementing t 2
	mov rax, t
	fld dword [rax] ; st0 = t
	mov rax, increment
	fld dword [rax] ;st0 = increment
	faddp ; st0 = t + increment

	;calculate next x
	mov rax, w1
	fld dword [rax] ;st0 = w
	; mov rax, t
	; fld dword [rax] ;st0 = t, st1 = w
	fmulp ; st0 = t*w 
	mov rax, d
	fld dword [rax] ;st0 = d, st1 = t*w
	faddp ;st0 = d + t*w
	fsin ;st0 = sin (d + t*w)
	mov rax, a
	fld dword [rax] ;st0 = a, st1 = sin (d + t*w)
	fmulp ; st0 = a * sin (d + t*w)
	mov rax, center_x
	fld dword [rax] ; st0 = center x, st1 =  a * sin (d + t*w)
	faddp ; st0 = center x + a * sin (d + t*w)
	mov rax, point_list + 16
	fstp dword [rax] ; point_list[0] =  center x + a * sin (d + t*w), st0 = empty
	; calculating next y
	mov rax, w2
	fld dword [rax] ; st0 = w2
	mov rax, t
	fld dword [rax] ;st0 = t
	fmulp ; st0 = w2*t
	fsin ; st0 = sin(w2*t)
	mov rax, b
	fld dword [rax] ;st0 = b, st1 = sin(w2*t)
	fmulp ; st0 = b*sin(t)
	mov rax, center_y
	fld dword [rax] ; st0 = center y, st1 = b*sin(w2*t)
	faddp ; st0 = center y + b*sin(t)
	mov rax, point_list + 20
	fstp dword [rax] ; point_list[1] =  center y + b*sin(w2*t), st0 = empty

; incrementing t 3
	mov rax, t
	fld dword [rax] ; st0 = t
	mov rax, increment
	fld dword [rax] ;st0 = increment
	faddp ; st0 = t + increment

	;calculate next x
	mov rax, w1
	fld dword [rax] ;st0 = w
	; mov rax, t
	; fld dword [rax] ;st0 = t, st1 = w
	fmulp ; st0 = t*w 
	mov rax, d
	fld dword [rax] ;st0 = d, st1 = t*w
	faddp ;st0 = d + t*w
	fsin ;st0 = sin (d + t*w)
	mov rax, a
	fld dword [rax] ;st0 = a, st1 = sin (d + t*w)
	fmulp ; st0 = a * sin (d + t*w)
	mov rax, center_x
	fld dword [rax] ; st0 = center x, st1 =  a * sin (d + t*w)
	faddp ; st0 = center x + a * sin (d + t*w)
	mov rax, point_list+24
	fstp dword [rax] ; point_list[0] =  center x + a * sin (d + t*w), st0 = empty
	; calculating next y
	mov rax, w2
	fld dword [rax] ; st0 = w2
	mov rax, t
	fld dword [rax] ;st0 = t
	fmulp ; st0 = w2*t
	fsin ; st0 = sin(w2*t)
	mov rax, b
	fld dword [rax] ;st0 = b, st1 = sin(w2*t)
	fmulp ; st0 = b*sin(t)
	mov rax, center_y
	fld dword [rax] ; st0 = center y, st1 = b*sin(w2*t)
	faddp ; st0 = center y + b*sin(t)
	mov rax, point_list+28
	fstp dword [rax] ; point_list[1] =  center y + b*sin(w2*t), st0 = empty

	mov rcx, point_list
	call custom_draw_spline ; draw the thing

	mov rax, t
	fld dword [rax];
	mov rax, pi_2
	fld dword [rax]; st0 = 2pi, st1 = t
	ucomiss xmm0, xmm1 ; 2pi ? t
	jg calculate_loop ; jump if 2pi > t


	



	

; Epilog
	pop rbp
	ret

