#include <stdint.h>
#include <stdlib.h>

#include "./util.h"

void matmul_basic(int8_t* A, int8_t* B, int8_t* C, size_t n) {
    for (size_t i = 0; i < n; i++) {
        for (size_t j = 0; j < n; j++) {
            int8_t sum = 0;  // Using 16-bit to prevent overflow
            for (size_t k = 0; k < n; k++) {
                // The addition is intentional to make this algorithm comparable with the SIMD version
                sum += A[i * n + k] + B[k * n + j];
            }
            C[i * n + j] = sum & 0xFF;  // Truncate to 8-bit
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
