# Femto-8 ASM Specification

- [Introduction](#introduction)
- [Source Files](#source-files)
- [General Syntax](#general-syntax)
- [Comments](#comments)
- [Labels](#labels)
- [Registers](#registers)
  - [Special registers and aliases](#special-registers-and-aliases)
    - [Status Register](#status-register)
- [Numeric Literals](#numeric-literals)
- [Instruction Syntax](#instruction-syntax)
- [Address Resolution](#address-resolution)
- [Pseudo-Instructions](#pseudo-instructions)
- [Stack Operations](#stack-operations)
- [Program Entry](#program-entry)
- [ABI Notes](#abi-notes)
  - [Registers](#registers-1)
  - [Arguments and return values](#arguments-and-return-values)
- [Appendix A](#appendix-a)
- [Appendix B](#appendix-b)

## Introduction

Femto-8 ASM is the official assembly language for the Femto-8 virtual CPU.

It provides a human-readable representation of Femto-8 machine code while introducing a number of assembler conveniences such as labels, pseudo-instructions and address resolution.

The assembler outputs Femto-8 Hex, which can be directly executed by the Femto-8 emulator.

This document specifies the syntax and semantics of the Femto-8 assembler.

## Source Files

A Femto-8 assembly source file is a plain text file.

The recommended file extension is `.asm`.

The assembler processes the source file from top to bottom.

## General Syntax

Each source line consists of one of the following:

- an instruction
- a label
- a comment
- a blank line

Example:

```asm
main:
    MOVI R0, 42
    MOVI R1, 17

    ADD R2, R1, R0

    JMP exit

exit:
```

Whitespace outside of tokens is ignored.

## Comments

Comments begin with a semicolon (`;`) and continue until the end of the line.

```asm
MOVI R0, 5      ; Load constant
```

Entire lines may also be comments.

```asm
; This function computes the factorial
```

## Labels

Labels define symbolic addresses.

Syntax:

```asm
label_name:
```

Labels occupy no program memory.

Example:

```asm
loop:
    DEC R0
    JNZ loop, R0
```

Labels may be referenced before or after their definition.

## Registers

All general purpose registers are 8-bit and are considered unsigned by the machine.

Registers are written as

```text
R0
R1
...
R10
```

Register names are case-insensitive.

Registers R0-R10 are available for general use.

Examples:

```asm
MOVI R0, 5
ADD R1, R2, R3
```

### Special registers and aliases

Alias | Register | Notes
------|----------|------
`SP`  | `R14`    | Discussed in detail in [Stack Operations](#stack-operations)
`FP`  | `R11`    | Discussed in detail in [Stack Operations](#stack-operations)
`SR`  | `R13`    | Alias to status register

#### Status Register

Currently, two bits are utlized.

- If the `0x1` bit is set, the last arithmetic operation computed to zero
    - Only `ADD` and `SUB` instructions set this bit when appropriate, all other instructions do not interact with this bit.

- If the `0x2` bit is set, the last arithmetic operation either produced a carry, or needed a borrow, whichever is appropriate
    - Only `ADD` and `SUB` instructions set this bit when appropriate, all other instructions do not interact with this bit

- Arithmetic operations on stack pointer do not interact with status register

- Status register is only valid on the very next instruction after an `ADD` or `SUB`

## Numeric Literals

The assembler supports the following literal formats.

Decimal

```text
42
```

Hexadecimal

```text
0x2A
```

Binary

```text
0b00101010
```

## Instruction Syntax

Instructions follow the syntax

```text
MNEMONIC operand1, operand2, ...
```

Mnemonics are case-sensitive

Example:

```asm
ADD R0, R1, R2
```

Commas are required between operands.

## Address Resolution

Jump instructions accept labels in place of explicit register pairs.

```asm
CALL fibonacci
```

The assembler automatically emits the instructions required to load the destination address before performing the jump.

Similarly,

```asm
JMP loop
```

is translated into the appropriate machine instructions.

Address resolution may emit additional instructions before the jump instruction. Consequently, the generated machine code may contain more instructions than the assembly source.

## Pseudo-Instructions

Pseudo-instructions are assembler conveniences.

They are expanded into one or more native Femto-8 instructions during assembly.

Pseudo-instructions do not exist in the ISA.

Example:

```asm
CLR R0
```

expands to

```asm
MOVI R0, 0
```

> See [Appendix B](#appendix-b) for a full list of pseudo-instructions

## Stack Operations

The assembler provides pseudo-instructions to interact with the stack.

```asm
PUSH R0
POP R0

PUSHI 42
```

These expand into the corresponding sequence of native instructions.

Other than that, the stack can be manually manipulated with `SP` and `FP` aliases. Using `SP` and `FP` other than as described below will result in undefined behaviour

Mnemonic                 | Notes
-------------------------|------
`ADD SP, SP, Rs`         |`SP <- SP + Rs`
`SUB SP, SP, Rs`         |`SP <- SP - Rs`
`LOAD Rd, [SP/FP], Rlo`  |`Rd <- mem[SP/FP + Rlo]`
`STORE Rs, [SP/FP], Rlo` |`Rs -> mem[SP/FP + Rlo]`

> Note that the stack grows downwards towards `0x0000`

> With `LOAD` and `STORE`, if `Rlo` is also one of `SP` or `FP`, the offset is 0

## Program Entry

Execution begins at the first emitted instruction.

The recommended convention is

```asm
main:
```

located at the beginning of the source file.

## ABI Notes

This section documents the official Femto-8 calling convention.

### Registers

Registers R0-R5 are caller saved, while registers R6-R10 are callee saved

### Arguments and return values

All arguments and return values are transferred through the stack. The caller pushes the arguments on the stack, and allocates any space necessary for return values before calling a function.

If any multi-byte data is to be transferred, it is preferred that all space be allocated on the stack beforehand, then offsets to the allocated spaces be pushed on as arguments

## Appendix A

A list of the 16 instructions in the ISA

Mnemonic            | Notes
--------------------|------
`ADD Rd, Rs, Rt`    | `Rd <- Rs + Rt`
`SUB Rd, Rs, Rt`    | `Rd <- Rs - Rt`
`AND Rd, Rs, Rt`    | `Rd <- Rs & Rt`
`OR Rd, Rs, Rt`     | `Rd <- Rs \| Rt`
`XOR Rd, Rs, Rt`    | `Rd <- Rs ^ Rt`
`NOT Rd, Rs`        | `Rd <- ~Rs`
`SHL Rd, Rs, Rt`    | `Rd <- Rs << Rt`
`SHR Rd, Rs, Rt`    | `Rd <- Rs >> Rt`
`MOVI Rd, imm`      | `Rd <- imm`
`LOAD Rd, Rhi, Rlo` | `Rd <- mem[(Rhi << 8)\|Rlo]`
`STORE Rs, Rhi, Rlo`| `Rs -> mem[(Rhi << 8)\|Rlo]`
`JMP label`         | Jumps to `label`
`JZ label, Rs`      | If `Rs == 0` then jumps to `label`
`JNZ label, Rs`     | If `Rs != 0` then jumps to `label`
`CALL label`        | Stores RA and FP to the stack, and jumps to `label`
`RET`               | Restores FP and then returns to stored RA

## Appendix B

Mnemonic            | Notes
--------------------|------
`PUSH Rs`           | Pushes `Rs` onto the stack
`POP Rd`            | Pops the top of the stack into `Rd`
`PUSHI imm`         | Pushes 8-bit `imm` value onto the stack
`MOV Rd Rs`         | `Rd <- Rs`
`INC Rd`            | `Rd <- Rd + 1`
`DEC Rd`            | `Rd <- Rd - 1`
`CLR Rd`            | `Rd <- 0`
`JE label, Ra, Rb`  | If `Ra == Rb` jump to `label`
`JNE label, Ra, Rb` | If `Ra != Rb` jump to `label`
`JLT label, Ra, Rb` | If `Ra < Rb` jump to `label`
