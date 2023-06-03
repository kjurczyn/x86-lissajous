; The registers RAX, RCX, RDX, R8, R9, R10, R11 are considered volatile (caller-saved).[25]
;The registers RBX, RBP, RDI, RSI, RSP, R12, R13, R14, and R15 are considered nonvolatile (callee-saved).[25]

section .data
	data: dq 0
	pitch: dd 0
	length: dd 0
	w1: dq 0
	w2: dq 0
	d: dq 0

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
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
; end prologue
	mov r12, 0 ; x
	mov r13, 0 ; y
	mov r14, 0 ; x + y
	; rcx = pointer
	; pitch = edx/rax
	mov rax, length
	mov r15d, [rax]
	mov rax, pitch
	mov r10d, [rax]
main_loop:
	xor r14, r14
	add r14, r13
	add r14, r12
	mov dword [rcx+r14], 0x0
	add r12, 4
	cmp r12, r15
	jl main_loop
	xor r12, r12
	add r13, r10
	cmp r13, 10000
	jl main_loop



; epilogue
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	