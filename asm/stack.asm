; For demonstration of stack: pass arguments and retrieve returned value from a subroutine using stack

main:
    ; Move out values
    MOVI R0, 78
    PUSH R0

    MOVI R0, 87
    PUSH R0

    ; Call the subroutine
    CALL addn

    ; Get the value into a register
    POP R0

    JMP exit

addn:
    ; Store return addresses
    POP R3
    POP R4

    ; Bring values into registers
    POP R1
    POP R2

    ; Perform addition
    ADD R1, R1, R2

    ; Push return value to the stack
    PUSH R1

    ; Push return addresses to the stack and return
    PUSH R4
    PUSH R3
    RET

exit: