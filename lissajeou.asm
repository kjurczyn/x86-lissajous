; The registers RAX, RCX, RDX, R8, R9, R10, R11 are considered volatile (caller-saved).[25]
;The registers RBX, RBP, RDI, RSI, RSP, R12, R13, R14, and R15 are considered nonvolatile (callee-saved).[25]

section .data
	interval: dq 0.001
	max: dq 6.283185307179586

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
	CVTSI2SD xmm3, r8
	 
	push rbp
	push rbx
	push r12
	push r13
	push r14
	push r15
	push rsi
	push rdi
	mov rbp, rsp

; end prologue

	
; preparing registers for loop
	finit
	mov r15, 0;
	cvtsi2sd xmm4, r15 ; t = 0
	mov r15, 1
	cvtsi2sd xmm10, r15
	subsd xmm3, xmm10
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
	mov dword [rcx+r13], 0xFFFFFFFF

	addsd xmm4, xmm5 ; increment t
	comisd xmm4, xmm6
	jb main_loop
	


; epilogue
	pop rdi
	pop rsi
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret