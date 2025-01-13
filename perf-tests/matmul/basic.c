#include <stdint.h>
#include <stdlib.h>

#include "./util.h"

// #define TESTING

void matmul_basic(int8_t* A, int8_t* B, int8_t* C, size_t m, size_t n, size_t p) {

    asm volatile ("li x31, 0xDEADBEEF");
    asm volatile ("li x31, 0x0");

    // iterate over rows of A
    for (size_t i = 0; i < m; i++) {

        // iterate over columns of B
        for (size_t j = 0; j < p; j++) {

            int8_t sum = 0;

            // Iterate over row/column entries and accumulate the products
            for (size_t k = 0; k < n; k++) {
                // The addition instead of multiplication is intentional to
                // make this algorithm comparable with the SIMD version
                sum += A[i * n + k] + B[k * p + j];
            }

            C[i * p + j] = sum;
        }
    }

    asm volatile ("li x31, 0xCAFECAFE");
    asm volatile ("li x31, 0x0");
}

int main(int argc, char *argv[]) {

    if (argc != 2) {
        printf("Usage: %s <size>\n", argv[0]);
        printf("size: matrix dimension (must be multiple of 8)\n");
        return 1;
    }

    // Parse size from command line
    size_t size = atoi(argv[1]);
    
    // Validate size is multiple of 8
    if (size % 8 != 0) {
        printf("Error: size must be multiple of 8\n");
        return 1;
    }

    size_t m = size;
    size_t n = size;
    size_t p = size;
    
    // Allocate matrices
    int8_t* A = malloc(m * n * sizeof(int8_t));
    int8_t* B = malloc(n * p * sizeof(int8_t));
    int8_t* result = malloc(m * p * sizeof(int8_t));

    // Initialization of matrices with values does not have an impact on
    // the number of instructions necessary to compute the result, so
    // the initialization can be omitted.
#ifdef TESTING
    srand(0);
    for(int i = 0; i < m * n; i++) A[i] = (rand() % 9) - 4; // Random numbers from -4 to 4
    for(int i = 0; i < n * p; i++) B[i] = (rand() % 9) - 4; // Random numbers from -4 to 4
#endif

    transpose_matrix_inplace(B, n);
    
    // Run both versions
    matmul_basic(A, B, result, m, n, p);
    
#ifdef TESTING
    printf("Matrix A\n");
    print_matrix(A, n);

    printf("\nMatrix B\n");
    print_matrix(B, n);

    printf("\nResult\n");
    print_matrix(result, n);
#endif
    
    free(result);
    free(A);
    free(B);

    return 0;
}

