; Teating out relative stack indexing and frame pointer
; And the new ABI:
; 1. R0 - R5 caller saved
; 2. R6 - R10 callee saved
; 3. Return value and arguments to be stored on the stack
; 4. The caller pushes arbitrary values onto the the stack to allocate space for the return value


main:
    ; First push two values to allocate space for return value
    PUSHI 0
    PUSHI 0

    ; Push arguments
    PUSHI 255
    PUSHI 255

    CALL u8_mul

    ; Pop the arguments
    POP R0
    POP R0

    ; Pop the return values
    POP R0
    POP R1

    JMP exit

; FP + 0: Argument 1
; FP + 1: Argument 2
; FP + 2: Return value lo
; FP + 3: Return value hi

;; u8 x u8 -> u16
u8_mul:
    ; Clear out R2 and R3 for use
    CLR R2
    CLR R3

    ; Load arguments into registers
    MOVI R5, 0
    LOAD R0, R11, R5

    INC R5
    LOAD R1, R11, R5


u8_mul_loop1:
    ; If R0 0, exit, decrement R0 otherwise
    JZ u8_mul_exit, R0
    DEC R0

    ; Perform addition
    ADD R2, R2, R1

    ; Account for carry generated
    SHR R4, R13, R5
    ADD R3, R3, R4

    JMP u8_mul_loop1

u8_mul_exit:
    MOVI R5, 2
    STORE R2, R11, R5

    INC R5
    STORE R3, R11, R5

    RET

exit:
