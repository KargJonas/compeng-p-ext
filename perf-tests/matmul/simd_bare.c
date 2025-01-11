#include <stdint.h>
#include <stdlib.h>

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
