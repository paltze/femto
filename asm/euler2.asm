; Solution to Prooject Euler problem 2, in FemtoASM

main:
    PUSHI 33
    CALL fib

    POP R0
    POP R1
    POP R2

    JMP exit


; ---- Fib Routine Start ---- ;

fib:
    ; Save return addresses
    POP R10
    POP R11

    ; Get n
    POP R0

    ;; Trivial cases when n = 0 and n = 1 ;;

    ; For n = 0
    JZ fib_return_1, R0

    ; For n = 1
    DEC R0
    JZ fib_return_2, R0

    ;; Loop Initiaization ;;

    ; Need n-2
    DEC R0

    ; Load initial values
    MOVI R1, 1
    CLR R2
    CLR R3

    MOVI R4, 2
    CLR R5
    CLR R6

    ; Accumulate values in R7, R8 and R9
    MOVI R7, 2 ; Should start with 2 because the even addition routine only works for Fibonacci numbers >= 3
    CLR R8
    CLR R9

    ; Jump to loop
    JMP fib_loop

fib_loop:
    ; Terminate loop
    JZ fib_return, R0

    ; Backup values
    PUSH R10
    PUSH R11
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R9
    PUSH R0

    ; Load arguments for routine
    PUSH R6
    PUSH R3
    PUSH R5
    PUSH R2
    PUSH R4
    PUSH R1

    CALL add24

    ; Restore values
    POP R4
    POP R5
    POP R6

    POP R0
    POP R9
    POP R8
    POP R7
    POP R3
    POP R2
    POP R1
    POP R11
    POP R10

    DEC R0

    ;; Check for even and accumulate ;;

    ; Clear R1 and R2 for use
    PUSH R1
    PUSH R2

    MOVI R1, 1
    AND R2, R4, R1

    JZ fib_accumulate_zero, R2
    
    ; Restore R1 and R2
    POP R2
    POP R1

    ; Call loop again
    JMP fib_loop

fib_accumulate_zero:
    ; Prepare to call add24
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R10
    PUSH R11

    ; Load arguments
    PUSH R6
    PUSH R9
    PUSH R5
    PUSH R8
    PUSH R4
    PUSH R7

    CALL add24

    POP R7
    POP R8
    POP R9

    ; Restore register values
    POP R11
    POP R10
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0

    ; Restore R1 and R2
    POP R2
    POP R1

    ; Call loop again
    JMP fib_loop


fib_return:
    PUSH R9
    PUSH R8
    PUSH R7
    JMP fib_terminate

fib_return_1:
    PUSHI 0
    PUSHI 0
    PUSHI 1
    JMP fib_terminate

fib_return_2:
    PUSHI 0
    PUSHI 0
    PUSHI 2
    JMP fib_terminate

fib_terminate:
    ; Push back return addresses and return
    PUSH R11
    PUSH R10
    RET    

; ----  Fib Routine End  ---- ;



; --- 24-bit Addition Routine Start --- ;
;; Argument pattern: [A0 B0 A1 B1 A2 B2]
add24:
    ; Store return addresses
    POP R10
    POP R11

    ;; The added value will be accumulated in R7, R8 and R9;;
    ;; R5 to be used to propogate carry ;;

    ;; Handling least significant bytes ;;
    POP R0
    POP R1

    ADD R7, R0, R1

    ; Catch a carry, if generated
    MOVI R5, 1
    SHR R5, R13, R5

    ;; Handling the next bytes ;;
    POP R0
    POP R1

    ADD R8, R0, R1

    ; Preserve current carry
    MOVI R6, 1
    SHR R6, R13, R6

    ; Add previous carry
    ADD R8, R8, R5

    ; Catch the newest carry generated
    MOVI R5, 1
    SHR R5, R13, R5

    ; Combine both carries
    OR R5, R5, R6

    ;; Handling the final bytes ;;

    ; Get the final bytes
    POP R0
    POP R1

    ; Add everything
    ADD R9, R0, R1
    ADD R9, R9, R5

    ; Push back values
    PUSH R9
    PUSH R8
    PUSH R7

    ; Push back return addresses and return
    PUSH R11
    PUSH R10
    RET

; ---  24-bit Addition Routine End  --- ;

exit:
