; Andrew Adler, Noah Snelson
; linearC
; Examples of calling linearASM in C++.
; In NetRun, be sure to set options as follows:
; Mode: whole functions, void foo(void), link with linearASM.

extern "C" void traverseMatrix(long * A, long Arows, long Acols);
extern "C" void addMatrix(long * A, long Arows, long Acols, long * B);
extern "C" void subMatrix(long * A, long Arows, long Acols, long * B);


void foo(void){
	long Arows = 3;
	long Acols = 3;
	long A[Arows][Acols] = {{10,10,10},{10,10,10},{10,10,10}};
	long B[Arows][Acols] = {{2,2,2},{2,2,2},{2,2,2}};
	long * ptrA = &A[0][0];
	long * ptrB = &B[0][0];
	
	traverseMatrix(ptrA, Arows, Acols);
	subMatrix(ptrA, Arows, Acols, ptrB);
	traverseMatrix(ptrA, Arows, Acols);
}