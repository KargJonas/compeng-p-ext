    .section .data
vecA:   .half 0x0003, 0x0005       # Initialize vector A with 16-bit values 3 and 5
vecB:   .half 0x0002, 0x0007       # Initialize vector B with 16-bit values 2 and 7

    .section .text
    .globl main
main:
    # Set up the vector length and type
    li t0, 2                        # Set vector length to 2 (two elements)
    vsetvli t0, t0, e16             # Configure vector registers to hold 16-bit elements

    # Load base addresses of vecA and vecB into registers
    la t1, vecA                     # Load address of vecA into t1
    la t2, vecB                     # Load address of vecB into t2
    la t3, result                   # Load address of result into t3

    # Load vecA and vecB into vector registers v0 and v1
    vle16.v v0, (t1)                # Load vector A from the address in t1 into v0
    vle16.v v1, (t2)                # Load vector B from the address in t2 into v1

    # Perform element-wise addition
    vadd.vv v2, v0, v1              # v2 = v0 + v1 (element-wise addition)

    # Store the result from v2 back to memory
    vse16.v v2, (t3)                # Store vector result from v2 to address in t3

    # Exit (Linux RISC-V convention)
    li a7, 93                       # System call number for exit
    ecall

    .section .data

result: .half 0x0000, 0x0000         # Placeholder to store the result
