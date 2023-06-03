; The registers RAX, RCX, RDX, R8, R9, R10, R11 are considered volatile (caller-saved).[25]
;The registers RBX, RBP, RDI, RSI, RSP, R12, R13, R14, and R15 are considered nonvolatile (callee-saved).[25]

section .data
	data: dq 0
	pitch: dd 0
	length: dd 0
	w1: dq 0
	w2: dq 0
	d: dq 0
	;middle: dd 0
	max: dq 0
	interval: dq 0.01

section .text
	global lissajous_draw
lissajous_draw:
; lissajous_draw(void* pixel_array, const unsigned int pitch, const unsigned int length, const double w1, const double w2, const double d)
; pixel address = data_pointer + x * pixel_size(4 bytes) + pitch * y
; rcx = pointer to pixel array
; prologue
	mov rax, data
	mov [rax], rcx
	mov rax, pitch
	mov [rax], edx
	mov rax, length
	mov [rax], r8d
	mov rax, w1
	fstp qword [rax]
	mov rax, w2
	fstp qword [rax]
	mov rax, d
	fstp qword [rax]
	 
	push rbp
	push rbx
	push r12
	push r13
	push r14
	push r15
	mov rbp, rsp
	sub rsp, 8

; end prologue
; calculating the center and 2pi
	mov r8, length
	mov dword [rsp+8], 2
	finit
	; fild dword [r8] ;st0 = length
	; fdiv dword [rsp+8] ;st0 = length/2
	; mov rax, middle
	; fistp dword [rax] 

	fldpi
	fild dword [rsp+8] ;st0 = 2, st1 = pi
	fmulp ; st0 = 2pi
	mov rax, max
	fstp qword [rax]


; preparing registers for loop
	xor r12, r12 ; x
	xor r13, r13 ; y
	xor r14, r14; x + y
; 	mov r8, length
	mov rbx, d
	; rcx = pointer
	; pitch = edx/rdx
	; length = [r8]
	; d = rbx
	mov rax, max
	fld qword [rax] ; st0 = t = 2pi
	mov r15, 1000
main_loop:
; calculating the x
	mov rax, w1
	fld qword [rax]
	fmul st0, st1 ; st0 = w1 * t, st1 = t
	
	fld qword [rbx] ; st0 = d, st1 = w1 * t, st2 = t
	fsubp ; st0 = w1 * t - d, st1 = t
	fcos ; st0 = cos (w1 * t - d), st1 = t
	
	fild dword [r8] ;st0 = length, st1 = cos (w1 * t - d), st2 = t
	fmulp
	fistp qword [rsp+8] ;st0 = t, stack = length * cos (w1 * t - d)

	mov r12, [rsp+8]
	imul r12, 4 ; r12 = x * 4
	mov eax, [r8]
	add r12, rax ; r12 = x * 4 + len/2
; calculating the y
	mov rax, w2
	fld qword [rax]
	fmul st0, st1 
	
	fld qword [rbx]
	fsubp
	fcos

	fild dword [r8]
	fmulp
	fistp qword [rsp+8]

	mov r13, [rsp+8]
	imul r13, rdx ; r13 = y * pitch

	mov eax, [r8]
	add r13, rax ; r13 = y * pitch + len/2

	mov r14, r13
	add r14, r12
	;mov dword [rcx+r14], 0x0

	mov rax, interval
	fld qword [rax]
	fsubp ; st0 = decremented t
	sub r15, 1
	test r15, r15
	jnz main_loop
		 


	



; epilogue
	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret