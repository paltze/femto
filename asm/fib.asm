; Fibonacci

    MOVI R0, 0          ; R0 = F(0) = 0
    MOVI R1, 1          ; R1 = F(1) = 1
    MOVI R2, 6          ; R2 = Loop counter (We need n-1 steps to reach F(n))
    MOVI R6, 1          ; R6 = Constant 1 for decrementing

loop:
    ADD R5, R0, R1      ; R5 = Next Fibonacci number
    AND R0, R1, R1      ; Shift: R0 = R1
    AND R1, R5, R5      ; Shift: R1 = R5
    
    SUB R2, R2, R6      ; Decrement loop counter
    JNZ loop, R2        ; If R2 != 0, go back to loop
