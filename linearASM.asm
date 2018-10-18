; Andrew Adler, Noah Snelson
; linear ASM
; x86 assembly library for linear algebra functions
; In NetRun, set options as follows:
; Mode: whole function, long foo(void), link with linearC.


global traverseMatrix
global addMatrix
global subMatrix
extern print_long
extern puts

; traverseMatrix : print contents of given matrix
; rdi = ptr to matrix A
; rsi = rows of A
; rdx = cols of A
traverseMatrix:
	mov rcx, rsi
	imul rcx, rdx ; gives total items of array
	push rdi
	push rcx
	mov rdi, openBracket
	call puts
	pop rcx
	pop rdi
	loopTraverse:
		push rdi
		push rcx
		mov rdi, [rdi]
		call print_long ; Print out item at rdi pointer
		pop rcx
		pop rdi
		add rdi, 8 ; Add size of one int
		loop loopTraverse
	mov rdi, closeBracket
	call puts
	mov rax, 0
	ret
	
; addMatrix : compute A+B element-wise
; rdi = ptr to matrix A
; rsi = rows of matrices
; rdx = cols of matrices
; rcx = ptr to matrix B
addMatrix:
	mov r9, rsi
	imul r9, rdx ; get total elements of array
	loopAdd:
		mov r8, [rdi]
		add r8, [rcx] ; add each element's value
		mov [rdi], r8   ; move new value into matrix A
		add rdi, 8	
		add rcx, 8	; increment both array pointers by one entry
		sub r9, 1
		cmp r9, 0
		jg loopAdd
	mov rax, 0
	ret

; subMatrix : compute A-B element wise
; rdi = ptr to matrix A
; rsi = rows of matrices
; rdx = cols of matrices
; rcx = ptr to matrix B	
subMatrix:
	mov r9, rsi
	imul r9, rdx ; get total elements of array
	loopSub:
		mov r8, [rdi]
		sub r8, [rcx] ; add each element's value
		mov [rdi], r8   ; move new value into matrix A
		add rdi, 8	
		add rcx, 8	; increment both array pointers by one entry
		sub r9, 1
		cmp r9, 0
		jg loopSub
	mov rax, 0
	ret
	
section .data

openBracket:
	db '[',0
closeBracket:
	db ']',0
matrixA:
	dq 0
Arows:
	dq 0
Acols:
	dq 0
	
matrixB:
	dq 0
Brows:
	dq 0
Bcols:
	dq 0