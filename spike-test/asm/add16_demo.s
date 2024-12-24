# add16_example.S

    .section .data
message:
    .string "ADD16 Result: 0x%08x\n"

    .section .text
    .global main

main:
    # Load immediate values into registers
    li a0, 0x1
    li a1, 0x0

    # Perform ADD16 operation (from B extension)
    andn a2, a0, a1    # a2 = add16(a0, a1)

    # Prepare arguments for printf
    la a0, message      # a0 = address of format string
    mv a1, a2           # a1 = result of ADD16

    # Call printf
    call printf

    # Exit the program
    li a0, 0            # Return code 0
    li a7, 93           # ECALL code for exit
    ecall
