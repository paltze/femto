; Trying to implement 32-bit addition
; First value in little endian format from R0 to R3
; Second value similarly from R4 to R7
; Result from R8 to R11
; No jump instructions used, R12 and R15 safe to be used as scratch

; Load 0x6D72BAED (1,836,235,501)
MOVI R0, 237
MOVI R1, 186
MOVI R2, 114
MOVI R3, 109

; Load 0xF238C66A (4,063,807,082)
MOVI R4, 106
MOVI R5, 198
MOVI R6, 56
MOVI R7, 242

; Load 1 into R15 for shifting
MOVI R15, 1

; Fill R8
ADD R8, R0, R4
SHR R12, R13, R15 ; Since R13 becomes 0x2 if there's a carry, R12 will hold 1 is there is a carry, 0 otherwise

; Fill R9
ADD R9, R1, R5
SHR R15, R13, R15 ; Catch the new carry
ADD R9, R9, R12 ; Add previous carry

MOVI R0, 1 ; R0 can now be used to permanently hold 1
SHR R12, R13, R0 ; Catch the new carry
OR R12, R12, R15 ; Carry to next term if any addition produced carry

; Repeat for R10

; R10
ADD R10, R2, R6
SHR R15, R13, R15
ADD R10, R10, R12
SHR R12, R13, R0
OR R12, R12, R15

; R11
ADD R11, R3, R7
ADD R11, R11, R12
