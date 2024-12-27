.global _start
_start:
    # Initialize the stack pointer
    la sp, stack_top

    andi t0, t0, 0 # Clear register t0
    andi t1, t1, 0 # Clear register t1
    andi t2, t2, 0 # Clear register t2
    andi t3, t3, 0 # Clear register t3
    andi t4, t4, 0 # Clear register t3
    li t0, 394     # Load register t0
    li t1, 19      # Load register t1
    # Muldiv
    mul t2, t0, t1
    # FP single and Double precision
    fcvt.s.w ft0, t2
    fcvt.d.w ft1, t1
    fdiv.d ft2, ft1, ft0
    fadd.s ft3, ft0, ft2
    fcvt.w.s t4, ft3
    # Psimd
    radd16 t3, t2, t4

    # Exit program
    j exit

.section .bss
.align 4
.skip 1024 # Reserve 1KB for the stack
stack_top:

exit:
    # Exit gracefully
    li a7, 10  # Syscall number for exit
    ecall
