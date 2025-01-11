#include <stdint.h>
#include <stdio.h>

void print_matrix(int8_t* data, size_t n) {
    for (size_t i = 0; i < n; i++) {
        for (size_t j = 0; j < n; j++) {
            printf("%6i ", data[i * n + j]);
        }
        printf("\n");
    }
}

void transpose_matrix_inplace(int8_t* matrix, size_t n) {
    for (size_t i = 0; i < n; i++) {
        for (size_t j = i + 1; j < n; j++) {  // Note: j starts from i+1
            // Swap elements at (i,j) and (j,i)
            int8_t temp = matrix[i * n + j];
            matrix[i * n + j] = matrix[j * n + i];
            matrix[j * n + i] = temp;
        }
    }
}
