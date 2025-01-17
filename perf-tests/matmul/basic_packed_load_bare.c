#include <stdint.h>
#include <stdlib.h>

void matmul_packed_load(int8_t* A, int8_t* B, int8_t* C, size_t m, size_t n, size_t p) {
    // Assumption: A is in row-major order, B is in column-major order
    // Assumption: m, n and p are multiples of 8

    for (size_t i = 0; i < m; i++) {     // Iterate over rows of A
        for (size_t j = 0; j < p; j++) { // Iterate over columns of B
            int8_t sum = 0;

            for (size_t k = 0; k < n; k += 8) {
                uint64_t a_chunk = *(uint64_t*)(A + i * n + k);
                uint64_t b_chunk = *(uint64_t*)(B + j * n + k);

                // Multiply corresponding bytes and accumulate
                for (int x = 0; x < 8; x++) {
                    int8_t a_val = (a_chunk >> (x * 8)) & 0xFF;
                    int8_t b_val = (b_chunk >> (x * 8)) & 0xFF;
                    sum += a_val * b_val;
                }
            }

            C[i * p + j] = sum;
        }
    }
}
