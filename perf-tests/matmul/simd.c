#include <stdint.h>
#include <stdlib.h>

#include "./util.h"

void matmul_simd(int8_t* A, int8_t* B, int8_t* C, size_t n) {


    for (size_t i = 0; i < n; i++) {
        for (size_t j = 0; j < n; j++) {
            int16_t sum = 0;
            // Now B is transposed so elements in a column are adjacent
            uint64_t a_chunk = *(uint64_t*)(A + i * n);
            uint64_t b_chunk = *(uint64_t*)(B + j * n); // j * n since B is transposed
            
            // Use add8 for SIMD operation
            uint64_t result;
            asm volatile (
                "add8 %[res], %[src1], %[src2]"
                : [res] "=r" (result)
                : [src1] "r" (a_chunk),
                  [src2] "r" (b_chunk)
            );
            
            // Extract and sum the individual bytes from result
            for (size_t k = 0; k < n; k++) {
                sum += ((int8_t*)&result)[k];
            }
            
            C[i * n + j] = (int8_t)sum;
        }
    }
}

int main() {
    size_t n = 3; // 3x3 matrix
    
    // Allocate matrices
    int8_t A[9] = {1,  2, 3,  -4, 2, 6,  2, 0, -3};
    int8_t B[9] = {5, -7, 1,   0, 1, 4,  2, 2,  3};
    int8_t* result = malloc(n * n * sizeof(int8_t));

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
