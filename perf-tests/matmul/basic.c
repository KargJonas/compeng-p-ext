#include <stdint.h>
#include <stdlib.h>

#include "./util.h"

void matmul_basic(int8_t* A, int8_t* B, int8_t* C, size_t n) {
    for (size_t i = 0; i < n; i++) {
        for (size_t j = 0; j < n; j++) {
            int16_t sum = 0;  // Using 16-bit to prevent overflow
            for (size_t k = 0; k < n; k++) {
                sum += A[i * n + k] + B[k * n + j];
            }
            C[i * n + j] = (int8_t)(sum & 0xFF);  // Truncate to 8-bit
        }
    }
}

int main() {
    size_t n = 3; // 3x3 matrix
    
    // Allocate matrices
    int8_t A[9] = {1,  2, 3,  -4, 2, 6,  2, 0, -3};
    int8_t B[9] = {5, -7, 1,   0, 1, 4,  2, 2,  3};
    int8_t* result = malloc(n * n * sizeof(int8_t));
    
    // Run both versions
    matmul_basic(A, B, result, n);
    
    printf("Matrix A\n");
    print_matrix(A, n);

    printf("\nMatrix B\n");
    print_matrix(B, n);

    printf("\nResult\n");
    print_matrix(result, n);
    
    free(result);

    return 0;
}
