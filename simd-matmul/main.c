#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

void simd_add_array(uint8_t* a, uint8_t* b, uint8_t* result, size_t length) {
    // Handle full 64-bit (8x8-bit) chunks
    size_t simd_chunks = length / 4;
    for(size_t i = 0; i < simd_chunks; i++) {
        // Process 4 elements at a time
        asm volatile (
            "add8 %[res], %[src1], %[src2]"
            : [res] "=r" (*(uint64_t*)(result + i*4))
            : [src1] "r" (*(uint64_t*)(a + i*4)),
              [src2] "r" (*(uint64_t*)(b + i*4))
        );
    }

    // Handle remaining elements (if length not divisible by 4)
    size_t remaining_start = simd_chunks * 4;
    for(size_t i = remaining_start; i < length; i++) {
        result[i] = a[i] + b[i];
    }
}

int main() {
    printf("RISC-V P Extension SIMD Addition Demo\n");

    size_t n = 256;

    uint8_t* a = malloc(n * sizeof(uint8_t));
    uint8_t* b = malloc(n * sizeof(uint8_t));
    uint8_t* result = malloc(n * sizeof(uint8_t));

    for (size_t i = 0; i < n; i++) {
        a[i] = i;
        b[i] = i + 1;
    }

    simd_add_array(a, b, result, n);

    // Print the results
    printf("Result of SIMD addition:\n");
    for (size_t i = 0; i < n; i++) {
        printf("%u + %u = %u\n", a[i], b[i], result[i]);
    }

    return 0;
}
