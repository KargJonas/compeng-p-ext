#include <stdint.h>
#include <stdlib.h>

void matmul_simd(int8_t* A, int8_t* B, int8_t* C, size_t m, size_t n, size_t p) {
  // Assumption: A is in row-major order, B is in column-major order
  // Assumption: m, n and p are multiples of 8

  for (size_t i = 0; i < m; i++) {    // Iterate over rows of A
    for (size_t j = 0; j < p; j++) {  // Iterate over columns of B
      register uint64_t tmp, result = 0;

      for (size_t k = 0; k < n; k += 8) {
        uint64_t a_chunk = *(uint64_t*)(A + i * n + k);
        uint64_t b_chunk = *(uint64_t*)(B + j * n + k);

        // Multiply eight eight 8-bit values at once
        asm volatile (
          "mul8 %[res], %[src1], %[src2]"
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

      // Horizontal summation (only done once per row/column pair)
      int8_t sum = 0;
      for (int x = 0; x < 8; x++) sum += (result >> (x * 8)) & 0xFF;
      
      C[i * p + j] = sum;
    }
  }
}
