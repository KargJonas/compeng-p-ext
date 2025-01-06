#include <stdio.h>
#include <stdint.h>

uint16_t a[4] = {1, 2, 3, 4};  // Example input vector A
uint16_t b[4] = {5, 6, 7, 8};  // Example input vector B
uint16_t result[4];            // Output vector to store results

// Function to perform SIMD addition using RISC-V P extension
void simd_add_demo() {
    // Use inline assembly for the P extension SIMD addition
    asm volatile (
        "add16 %[res], %[src1], %[src2]" // SIMD addition of 16-bit elements
        : [res] "=r" (*(uint64_t *)result) // Output operand
        : [src1] "r" (*(uint64_t *)a),     // Input operand 1
          [src2] "r" (*(uint64_t *)b)      // Input operand 2
    );

    // Print the results
    printf("Result of SIMD addition:\n");
    for (int i = 0; i < 4; i++) {
        printf("%u + %u = %u\n", a[i], b[i], result[i]);
    }
}

int main() {
    printf("RISC-V P Extension SIMD Addition Demo\n");
    simd_add_demo();
    return 0;
}
