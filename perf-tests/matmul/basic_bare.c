#include <stdint.h>
#include <stdlib.h>

void matmul_packed_load(int8_t* A, int8_t* B, int8_t* C, size_t m, size_t n, size_t p) {

    // iterate over rows of A
    for (size_t i = 0; i < m; i++) {

        // iterate over columns of B
        for (size_t j = 0; j < p; j++) {

            int8_t sum = 0;

            for (size_t k = 0; k < n; k++) {
                sum += A[i * n + k] * B[k * p + j];
            }

            C[i * p + j] = sum;
        }
    }
}
