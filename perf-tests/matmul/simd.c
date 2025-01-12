#include <stdint.h>
#include <stdlib.h>

#include "./util.h"

// This only handles square matrices for simplicity
void matmul_simd(int8_t* A, int8_t* B, int8_t* C, size_t n) {
    // Assumption: A is in row-major order, B is in column-major order
    // Assumption: n is a multiple of 8

    // iterate over rows of A
    for (size_t i = 0; i < n; i++) {

        // iterate over columns of B
        for (size_t j = 0; j < n; j++) {
            uint64_t tmp, result = 0;

            // We can multiply eight 8-bit values at once
            for (size_t k = 0; k < n; k += 8) {
                // B is transposed, so elements in a column are adjacent
                uint64_t a_chunk = *(uint64_t*)(A + i * n + k);
                uint64_t b_chunk = *(uint64_t*)(B + j * n + k);

                // Use add8 for SIMD operation instead of mul8 because I cant
                // get mul8 to work with my compiler
                asm volatile (
                    "add8 %[res], %[src1], %[src2]"
                    : [res] "=r" (tmp)
                    : [src1] "r" (a_chunk),
                      [src2] "r" (b_chunk)
                );

                // Aggregation of packed multiplication results
                // The add8 here is not a placeholder.
                asm volatile (
                    "add8 %[res], %[src1], %[src2]"
                    : [res] "=r" (result)
                    : [src1] "r" (result),
                      [src2] "r" (tmp)
                );
            }

            int8_t sum = 0;
            
            // Extract and sum the individual bytes from result
            // This can be done way more efficiently
            for (size_t k = 0; k < 8; k++) {
                sum += ((int8_t*)&result)[k];
            }
            
            C[i * n + j] = sum;
        }
    }
}

int main() {
    srand(0);

    size_t n = 16;
    size_t nelem = n * n;
    size_t nbytes = nelem * sizeof(int8_t);
    
    // Allocate matrices
    int8_t* A = malloc(nbytes);
    int8_t* B = malloc(nbytes);
    int8_t* result = malloc(nbytes);
    
    // Fill matrices with random numbers
    // Since we're multiplying matrices, keep numbers small (-4 to 4)
    // to prevent overflow (max result would be 4 * 4 * 3 = 48)
    for(int i = 0; i < nelem; i++) {
        A[i] = (rand() % 9) - 4;  // Random numbers from -4 to 4
        B[i] = (rand() % 9) - 4;
    }

    transpose_matrix_inplace(B, n);
    
    // Run both versions
    matmul_simd(A, B, result, n);
    
    printf("Matrix A\n");
    print_matrix(A, n);

    printf("\nMatrix B\n");
    print_matrix(B, n);

    printf("\nResult\n");
    print_matrix(result, n);
    
    free(result);

    return 0;
}
