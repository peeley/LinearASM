; Andrew Adler, Noah Snelson
; linear ASM
; x86 assembly library for linear algebra functions
; In NetRun, set options as follows:
; Mode: whole function, long foo(void), link with linearC.

global traverseMatrix
global addMatrix
global subMatrix
global mulMatrix
extern print_long
extern printf
extern puts

; traverseMatrix : print contents of given matrix
; rdi = ptr to matrix A (gets changed to rdx to pass to printf)
; rsi = rows of A
; rdx = cols of A
traverseMatrix:
	mov rcx, rsi					; number of rows
	imul rcx, rdx 					; gives total items of array (rows x cols)
	
	mov QWORD[Acols], rdx			; stores number of cols
		
	mov rdx, rdi					; pointer to matrix
			
	mov r8, 0						; iterator through matrix
	mov QWORd[mostDigits],0
	findBiggestDigit:				; find number of digits in largest number of matrix
		mov r9, 0					; where number of digits is stored temporarily
		cmp QWORD[rdx+r8*8],10
		jl one
		cmp QWORD[rdx+r8*8],100
		jl two
		cmp QWORD[rdx+r8*8],1000
		jl three
		cmp QWORD[rdx+r8*8],10000
		jl four
		cmp QWORD[rdx+r8*8],100000
		jl five
		
		five:
		add r9,1
		four:
		add r9,1
		three:
		add r9,1
		two:
		add r9,1
		one:
		add r9,1
		
		cmp QWORD[mostDigits],r9
		jg bigger
		mov QWORD[mostDigits],r9	; store number of digits if it is bigger that what is
										; currently stored
		bigger:
		
		add r8, 1
		cmp r8, rcx
		jne findBiggestDigit
		
	push rdx
	push rcx
	mov rdi, openBracket			; print bracket at start of array
	call puts
	pop rcx
	pop rdx
	
	loopTraverse:					; loop through matrix
		push rdi					; registers to preserve between loops
		push rdx
		push rcx
		
		mov rdi, formatIntWidth		; formatIntWidth: db `%*d`,0
		mov rsi, QWORD[mostDigits]
		mov rdx, [rdx]				; the value in the matrix
		call printf 				; Print out item at rdx pointer
		
		mov rdi, formatChar			
		mov rsi, ' '
		call printf					; to print a space between matrix elements
		
		cmp QWORD[Acols],1			; if there is only 1 column, always print new line
		je newLine
		
		mov rax, [rsp]
		mov rcx, [Acols]
		mov rdx, 0
		div rcx						; returns (rax mod rcx) in rdx
		cmp rdx, 1					; when (currentCol mod numCols) = 1, print a new line
		
		jne noNewLine
		newLine:
			mov rdi, formatNewLine
			call printf
		noNewLine:
		
		pop rcx
		pop rdx
		pop rdi
		add rdx, 8 					; Add size of one int
		
		sub rcx, 1					; decrement counter
		cmp rcx, 0
		jne loopTraverse
	
	mov rdi, closeBracket
	call puts
	ret
	
; addMatrix : compute A+B element-wise
; rdi = ptr to matrix A
; rsi = rows of matrices
; rdx = cols of matrices
; rcx = ptr to matrix B
addMatrix:
	mov r9, rsi
	imul r9, rdx			; get total elements of array
	loopAdd:
		mov r8, [rdi]
		add r8, [rcx] 		; add each element's value
		mov [rdi], r		; move new value into matrix A
		add rdi, 8	
		add rcx, 8			; increment both array pointers by one entry
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
	imul r9, rdx 			; get total elements of array
	loopSub:
		mov r8, [rdi]
		sub r8, [rcx		; add each element's value
		mov [rdi], r8   	; move new value into matrix A
		add rdi, 8	
		add rcx, 8			; increment both array pointers by one entry
		sub r9, 1
		cmp r9, 0
		jg loopSub
	mov rax, 0
	ret

; mulMatrix : compute A*B element wise
; rdi = ptr to matrix A
; rsi = rows of matrix A
; rdx = cols of matrice A
; rcx = ptr to matrix B	
; r8  = rows of matrix B
; r9  = cols of matrix B
; [rsp+8] = ptr to matrix C
mulMatrix:
	mov r10,[rsp+8]			; ptr to matrix C (result matrix)
	
	mov QWORD[Arows], rsi
	mov QWORD[Acols], rdx
	mov QWORD[Brows], r8
	mov QWORD[Bcols], r9
	
							; rdi is ptr to matrix A
	mov rsi, rcx			; ptr to matrix B
	
	imul r9,8
	mov QWORD[nextRowB],r9	; memory space to move to get to next row of matrix B
	
	mov rcx, 0				; counter for Acols and Brows
	mov rdx, 0				; counter for Arows
	mov r8, 0				; counter for Bcols
	
	rowALoop:				; loop through the rows of matrix A
		mov r8, 0
		colBLoop:			; loop through the columns of matrix B
			mov rax, 0
			mov rcx, 0
			generalLoop:	; loop through the columns of A and rows of B
							; to find which elements of each matrix need to be multiplied
				push rax					; keep a running total of multiplied elements
				mov rax, QWORD[rdi+rcx*8]	; element of matrix A to be multiplied
				mov r9, QWORD[nextRowB]		; memory to move to next row of B
				imul r9, rcx				; number of rows of B to move
				push r9
				mov r9, 0					
				add r9, r8					; number of columns of B to move
				imul r9, 8					; start of the column of B being multiplied
				add [rsp],r9				; including column offset to rows moved
				pop r9
				imul rax, QWORD[rsi+r9]		; multiply element of A by corresponding 
												; element of B
				add QWORD[rsp],rax			; adds value to running total
				pop rax
				
				add rcx,1
				cmp rcx, QWORD[Acols]
				jne generalLoop
				
			mov QWORD[r10],rax				; set value in matrix C
			add r10, 8						; move to next value in matrix C
			
			add r8,1
			cmp r8, QWORD[Bcols]
			jne colBLoop
		
		mov rax, QWORD[Acols]				; number of columns in matrix A
		imul rax, 8							; memory space in one column of matrix A
		add rdi,rax							; move matrix A pointer to next row
		
		add rdx, 1	
		cmp rdx, QWORD[Arows]
		jne rowALoop
	
	mov rax, 0
	ret
	
formatNewLine:
	db `\n`,0

formatChar:
	db `%c`,0
	
formatInt:
	db `%d`,0
formatIntWidth:
	db `%*d`,0

openBracket:
	db '[',0
closeBracket:
	db ']',0
	
section .data
mostDigits:
	dq 0

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
	
nextRowB:
	dq 0