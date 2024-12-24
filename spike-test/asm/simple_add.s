# simple_add.S

    .section .data
message:
    .string "Result: %d\n"

    .section .text
    .global main

main:
    # Load immediate values into registers
    li a0, 10       # Load 10 into register a0
    li a1, 20       # Load 20 into register a1

    # Perform addition
    add a2, a0, a1  # a2 = a0 + a1

    # Prepare arguments for printf
    la a0, message  # a0 = address of format string
    mv a1, a2       # a1 = result of addition

    # Call printf (assuming pk provides it)
    call printf

    # Exit the program
    li a0, 0        # Return code 0
    li a7, 93       # ECALL code for exit
    ecall
