#include <stdint.h>
#include <stdlib.h>

#include "./util.h"

void matmul_basic(int8_t* A, int8_t* B, int8_t* C, size_t m, size_t n, size_t p) {

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
}

int main() {
    srand(0);

    size_t m = 8, n = 16, p = 18;
    
    // Allocate matrices
    int8_t* A = malloc(m * n * sizeof(int8_t));
    int8_t* B = malloc(n * p * sizeof(int8_t));
    int8_t* result = malloc(m * p * sizeof(int8_t));
    
    // Fill matrices with random numbers
    // Since we're multiplying matrices, keep numbers small (-4 to 4)
    // to prevent overflow (max result would be 4 * 4 * 3 = 48)
    for(int i = 0; i < m * n; i++) A[i] = (rand() % 9) - 4; // Random numbers from -4 to 4
    for(int i = 0; i < n * p; i++) B[i] = (rand() % 9) - 4; // Random numbers from -4 to 4

    // Run both versions
    matmul_basic(A, B, result, n, n, n);
    
    printf("Matrix A\n");
    print_matrix(A, n);

    printf("\nMatrix B\n");
    print_matrix(B, n);

    printf("\nResult\n");
    print_matrix(result, n);
    
    free(result);

    return 0;
}

