; Calculating nth Fibonacci number using recursion 0, 1, 1, 2, 3, ...

main:
    MOVI R0, 9 ; The nth number to find

    PUSH R0

    CALL fib

    POP R0
    JMP exit


fib:
    ; --- Store the return addresses --- ;
    POP R11
    POP R10

    ; Get n
    POP R1



    ; --- Base Cases --- ;

    ; Check for base case n = 0
    JZ fib_return_0, R1

    ; Check for base case n = 1
    MOVI R2, 1                      ; R2 permanently 1 from now
    SUB R1, R1, R2
    JZ fib_return_1, R1




    ; --- Get fib(n - 1) into R3 --- ;

    ; Preserve the register values
    PUSH R11
    PUSH R10
    PUSH R1

    ; Call fib(n - 1)
    PUSH R1
    CALL fib
    POP R3

    ; Restore register values
    POP R1
    POP R10
    POP R11



    ; --- Get fib(n - 2) into R4 --- ;

    ; Preserve the register values
    PUSH R11
    PUSH R10
    PUSH R3

    ; Get fib(n - 2) into R4
    SUB R1, R1, R2
    PUSH R1
    CALL fib
    POP R4

    ; Restore register values
    POP R3
    POP R10
    POP R11



    ; --- Calculate final value and return --- ;

    ; Calculate fib(n - 1) + fib(n - 2)
    ADD R3, R3, R4

    PUSH R3

    JMP fib_return

fib_return_0:
    MOVI R1, 0
    PUSH R1

    JMP fib_return

fib_return_1:
    MOVI R1, 1
    PUSH R1

    JMP fib_return

fib_return:
    ; Push back return addresses and return
    PUSH R10
    PUSH R11
    RET

exit:
