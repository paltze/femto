; Solution to Project Euler #2
; - New ABI
; - Relative stack indexing

main:
    ; Allocate space for return value
    MOVI R0, 4
    SUB R14, R14, R0

    CALL solve

    POP R0
    POP R1
    POP R2
    POP R3

    JMP exit


; --- Solve Routine Start --- ;

solve:
    ; For the final solution
    ; Starting with two because further Fibonacci numbers generated are >= 3
    MOVI R0, 3
    SUB R14, R14, R0
    PUSHI 2

    ; Initialize 1 and 2 on the stack
    SUB R14, R14, R0
    PUSHI 1

    SUB R14, R14, R0
    PUSHI 2

    ; Space for scratch calculations
    MOVI R0, 4
    SUB R14, R14, R0

    ; Number of Fib iterations
    MOVI R6, 31

solve_loop1:
    JZ solve_exit, R6
    DEC R6

    ; Calculate a + b
    PUSHI 4
    PUSHI 8
    PUSHI 12
    PUSHI 4

    CALL u_nbyte_add
    MOVI R0, 4
    ADD R14, R14, R0


    ; Move values
    MOVI R7, 3

    PUSHI 11
    PUSHI 7
    PUSHI 4

    CALL smemcpy
    ADD R14, R14, R7

    PUSHI 7
    PUSHI 3
    PUSHI 4

    CALL smemcpy
    ADD R14, R14, R7

    ; Check if even, if so accumulate
    MOVI R1, 4
    LOAD R0, R14, R1

    MOVI R1, 1
    AND R0, R0, R1

    JZ solve_accumulate, R0


    JMP solve_loop1

solve_accumulate:
    PUSHI 16
    PUSHI 16
    PUSHI 8
    PUSHI 4

    CALL u_nbyte_add
    MOVI R0, 4
    ADD R14, R14, R0

    JMP solve_loop1

solve_exit:
    ; Deallocate the top three 32-bit numbers, leaving behind only the final solution
    MOVI R0, 12
    ADD R14, R14, R0

    PUSHI 11 ; Extra four byte offset because the hardware automatically store RA and FP on the stack on function call
    PUSHI 3
    PUSHI 4

    CALL smemcpy

    ; Deallocate the arguments and the final four bytes
    MOVI R0, 7
    ADD R14, R14, R0

    RET

; ---  Solve Routine End  --- ;

; --- memcpy n-bytes relative to FP start --- ;

;; Let FP + 0 = n
;; Let FP + 1 = a
;; Let FP + 2 = b
;; Copies values at FP + a_i into FP + b_i

smemcpy:
    ; Load n
    MOVI R0, 0
    LOAD R0, R11, R0

    MOVI R1, 1
    LOAD R1, R11, R1
    
    MOVI R2, 2
    LOAD R2, R11, R2

smemcpy_loop_1:
    JZ smemcpy_exit, R0
    DEC R0

    LOAD R3, R11, R1
    STORE R3, R11, R2

    INC R1
    INC R2

    JMP smemcpy_loop_1

smemcpy_exit:
    RET

; ---  memcpy n-bytes relative to FP end  --- ;

; --- n-byte Addition Routine Start --- ;

;; Computes c = a + b, where a, b and c are n-byte integers

;; Arguments
;; FP + 0: n - The number of bytes the arithmetic has to be performed
;; FP + 1: a - Index of lowest byte of "a" relative to FP, assuming that the next byte (if it exists) is at "FP + a + 1" and so on 
;; FP + 2: b - Similar for "b"
;; FP + 3: c - Similar for "c"

u_nbyte_add:
    ;; R0 and R1 used for active addition
    ;; R2 and R3 for carry propogation
    ;; R4, R5 and R6 for accessing the stack
    ;; R7 for n

    ; Since R6 and R7 are callee saved
    PUSH R6
    PUSH R7

    ; Load n
    CLR R0
    LOAD R7, R11, R0

    ; Load initial values
    MOVI R0, 1
    LOAD R4, R11, R0

    MOVI R0, 2
    LOAD R5, R11, R0
    
    MOVI R0, 3
    LOAD R6, R11, R0

    CLR R2
    CLR R3

u_nbyte_add_loop1:
    JZ u_nbyte_add_exit, R7
    DEC R7

    ; Get the two bytes to add
    LOAD R0, R11, R4
    INC R4

    LOAD R1, R11, R5
    INC R5

    ; Add them and store carry in R3
    ADD R1, R1, R0
    
    MOVI R0, 1
    SHR R3, R13, R0

    ; Add previous carry and catch the new carry in R2
    ADD R1, R1, R2
    SHR R2, R13, R0

    ; Total carry for this byte
    OR R2, R2, R3

    ; Store current byte
    STORE R1, R11, R6
    INC R6

    JMP u_nbyte_add_loop1

u_nbyte_add_exit:
    POP R7
    POP R6
    RET

; ---  n-byte Addition Routine End  --- ;

exit:
