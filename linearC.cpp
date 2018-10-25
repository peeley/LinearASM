// Andrew Adler, Noah Snelson
// linearC
// Examples of calling linearASM in C++.
// In NetRun, be sure to set options as follows:
// Mode: whole functions, void foo(void), link with linearASM.

extern "C" void traverseMatrix(long * A, long Arows, long Acols);
extern "C" void addMatrix(long * A, long Arows, long Acols, long * B);
extern "C" void subMatrix(long * A, long Arows, long Acols, long * B);
extern "C" void mulMatrix(long * A, long Arows, long Acols,
						  long * B, long Brows, long Bcols,
						  long * C);

void testAdd(void) {
	printf("Testing addition:\n");
	long Arows = 3;
	long Acols = 4;
	long A[Arows][Acols] = {{10,10,10,100},{10,10,10,10},{10,10,10,10}};
	long B[Arows][Acols] = {{2,2,2,2},{2,2,2,2},{2,2,2,2}};
	long * ptrA = &A[0][0];
	long * ptrB = &B[0][0];

	traverseMatrix(ptrA, Arows, Acols);
	printf("+\n");
	traverseMatrix(ptrB, Arows, Acols);
	addMatrix(ptrA, Arows, Acols, ptrB);
	printf("=\n");
	traverseMatrix(ptrA, Arows, Acols);
	printf("\n");
}

void testMul(void) {
	printf("Testing multiplication:\n");
	long Arows = 3;
	long Acols = 4;
	long Brows = Acols;
	long Bcols = 2;
	long A[Arows][Acols] = {{10,10,10,10},{10,10,10,10},{10,10,10,10}};
	long B[Brows][Bcols] = {{1,2},{1,2},{1,2},{1,2}};
	long C[Arows][Bcols] = {};
	long * ptrA = &A[0][0];
	long * ptrB = &B[0][0];
	long * ptrC = &C[0][0];
	
	traverseMatrix(ptrA, Arows, Acols);
	printf("*\n");
	traverseMatrix(ptrB, Brows, Bcols);
	printf("=\n");
	mulMatrix(ptrA, Arows, Acols, ptrB, Brows, Bcols, ptrC);
	traverseMatrix(ptrC, Arows, Bcols);
	printf("\n");
}

void foo(void){
	testAdd();
	testMul();
}