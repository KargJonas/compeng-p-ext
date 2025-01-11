#include <stdint.h>
#include <stdlib.h>

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
