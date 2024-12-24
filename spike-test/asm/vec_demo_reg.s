#
# this can be compiled with:
#   riscv64-unknown-elf-gcc -march=rv64gcv_zba_zbb_zbc_zbs vec_demo_reg.s -o vec_demo_reg && spike --isa=rv64gcv $PK vec_demo_reg
#


    .section .data
message:
    .string "Result: %d  %d\n"

    .section .text
    .globl main
main:
    # Set up the vector length and type
    # Because we first copy 64 bits from the temporaries into the vector register
    # as a whole, we have to set the vector size to 64 to prevent issues.
    li t0, 1                        # Set vector length to 4 (four elements)
    vsetvli t0, t0, e64             # Configure vector registers to hold 16-bit elements

    # Load immediates into temporaries
    li t1, 0x0001000100010001
    li t2, 0x0002000300040005

    # Copy data from temporaries into vector registers
    vmv.v.x v0, t1
    vmv.v.x v1, t2

    # Now that the data is in the vec regs, we can switch to 4x16
    li t0, 4                        # Vector length of 4 elements
    vsetvli t0, t0, e16             # SEW = 16 bits

    # Perform element-wise addition on vec regs
    vadd.vv v2, v0, v1              # v2 = v0 + v1 (element-wise addition)

    vmv.x.s a1, v2              # copy first element from vector register v2 to scalar register a1
    vslide1down.vx v2, v2, x0   # shift elements in v2 down by 1 such that the next element is the first in the vector register
    vmv.x.s a2, v2              # copy first element from vector register v2 to scalar register a1

    la a0, message
    call printf

    # Exit (Linux RISC-V convention)
    li a7, 93                       # System call number for exit
    ecall

    .section .data
