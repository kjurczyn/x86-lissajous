; The registers RAX, RCX, RDX, R8, R9, R10, R11 are considered volatile (caller-saved).[25]
;The registers RBX, RBP, RDI, RSI, RSP, R12, R13, R14, and R15 are considered nonvolatile (callee-saved).[25]

section .data
	data: dq 0
	pitch: dd 0
	length: dd 0
	w1: dq 0
	w2: dq 0
	d: dq 0
	temp: dq 0
	interval: dq 0.01
	max: dq 6.283185307179586
	t: dq 0

section .text
	global lissajous_draw
lissajous_draw:
; lissajous_draw(void* pixel_array, const unsigned int pitch, const unsigned int length, const double w1, const double w2, const double d)
; pixel address = data_pointer + x * pixel_size(4 bytes) + pitch * y
; rcx = pointer to pixel array
; xmm0 = w1
; xmm1 = w2
; xmm2 = d
; xmm3 = length
; xmm4 = t
; xmm5 = interval
; xmm6 = 2pi
; xmm7 = x
; xmm8 - y
; prologue
	mov rax, data
	mov [rax], rcx
	mov rax, pitch
	mov [rax], edx
	mov rax, length
	mov dword [rax], r8d
	CVTSI2SD xmm3, r8
	mov rax, w1
	movsd [rax], xmm0 
	mov rax, w2
	movsd [rax], xmm1
	mov rax, d
	movsd [rax], xmm2
	 
	push rbp
	push rbx
	push r12
	push r13
	push r14
	push r15
	push rsi
	push rdi
	mov rbp, rsp
	;sub rsp, 64

; end prologue

	
; preparing registers for loop
	finit
	mov r15, 0;
	cvtsi2sd xmm4, r15 ; t = 0
	mov rax, interval
	movsd xmm5, [rax]
	mov rax, max
	movsd xmm6, [rax]
; xmm0 = w1
; xmm1 = w2
; xmm2 = d
; xmm3 = length
; xmm4 = t
; xmm5 = interval
; xmm6 = 2pi
; xmm7 = x
; xmm8 - y
main_loop:
	;calc x
	movsd xmm7, xmm0
	mulsd xmm7, xmm4
	movsd [rsp-64], xmm7
	fld qword [rsp-64]
	fsin
	fstp qword [rsp-64]
	movsd xmm7, [rsp-64]
	mulsd xmm7, xmm3
	CVTSD2SI r12, xmm7

	add r12, r8
	shl r12, 2
	

	;calc y
	movsd xmm8, xmm1
	mulsd xmm8, xmm4
	movsd [rsp-64], xmm8
	fld qword [rsp-64]
	fsin
	fstp qword [rsp-64]
	movsd xmm8, [rsp-64]
	mulsd xmm8, xmm3
	CVTSD2SI r13, xmm8

	add r13, r8
	imul r13, rdx

	; color pixel	
	add r13, r12
	mov dword [rcx+r13], 0x000000FF

	addsd xmm4, xmm5 ; increment t
	comisd xmm4, xmm6
	jb main_loop
	


; epilogue
	;add rsp, 64
	pop rdi
	pop rsi
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret