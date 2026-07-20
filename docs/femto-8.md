# The Femto-8 Virtual CPU

## Femto-8 Hex

Femto-8 Hex is the default format of a program executable on the virtual CPU

- It is a plain-text file with each line containing the 2 bytes of a single instruction in hexadecimal encoding

- The execution starts at the very first instruction, then sequentially to the next instruction, unless jumped to a specific instruction

### The program in memory

Any program being executed is loaded into the memory starting at memory location `0x0000`, in little endian format

## Registers

### General Purpose Registers
`$r0` to `$r10`, and `$r12` and `$r15` are available for general use. These are 8-bit unsigned integer registers.

### Special Registers

#### Frame Pointer Alias: `$r11`

Reserved as a pointer to the special 16-bit frame pointer register, it points to the start of the current function call frame, automatically handled by `CALL` and `RET` instructions. Any reference to `$r11` except as `$rhi` in an M-type instruction is undefined.

#### Status Register: `$r13`
Currently, two bits are utlized.

- If the `0x1` bit is set, the last arithmetic operation computed to zero
    - Only `ADD` and `SUB` instructions set this bit when appropriate, all other instructions do not interact with this bit.

- If the `0x2` bit is set, the last arithmetic operation either produced a carry, or needed a borrow, whichever is appropriate
    - Only `ADD` and `SUB` instructions set this bit when appropriate, all other instructions do not interact with this bit
    - Arithmetic operations on stack pointer does not interact with status register

- Arithmetic operations on stack pointer do not interact with status register



#### Stack Pointer Alias: `$r14`

Reserved as a pointer to the special 16-bit stack pointer register, it points to the current location of the stack. Automatically handled by `CALL` and `RET` instructions. If FP and SP do not match when `RET` is called, an error is thrown and program execution halts. Any reference to `$r14` except as `$rhi` in M-type instructions, and as both `$rs` and `$rd` in `ADD` and `SUB` instructions is undefined.


## Instructions

A total of 16 instructions of 4 types

### Types

 Type | Format 
------|--------
 R    | `[opcode][rd][rs][rt]`
 I    | `[opcode][rd][imm]`
 M    | `[opcode][rs][rhi][rlo]`
 J    | `[opcode][rhi][rlo][rs]`

 - All registers are 4-bit values, immediate value is 8-bit.
 - Register value can point to any register if the register is not utilized in the instruction
 - For J type instructions, memory address of the instruction to jump to has to be stored in a pair of registers 

### List

Opcode | Name  | Type | Notes
-------|-------| -----| ------
0      |`ADD`  | R    |`$rd <- $rs + $rt`
1      |`SUB`  | R    |`$rd <- $rs - $rt`
2      |`AND`  | R    |`$rd <- $rs & $rt`
3      |`OR`   | R    |`$rd <- $rs \| $rt`
4      |`XOR`  | R    |`$rd <- $rs ^ $rt`
5      |`NOT`  | R    |`$rd <- ~$rs` (`$rt` is not utilized)
6      |`SHL`  | R    |`$rd <- $rs << $rt`
7      |`SHR`  | R    |`$rd <- $rs >> $rt`
8      |`MOVI` | I    |`$rd <- imm`
9      |`LOAD` | M    |`$rs <- mem[($rhi << 8)\|$rlo]`
A      |`STORE`| M    |`$rs -> mem[($rhi << 8)\|$rlo]`
B      |`JMP`  | J    |`$pc <- $rhi\|$rlo` (`$rs` is not utilized)
C      |`JZ`   | J    |If `$rs == 0` then `$pc <- ($rhi << 8)\|$rlo]`
D      |`JNZ`  | J    |If `$rs != 0` then `$pc <- ($rhi << 8)\|$rlo]`
E      |`CALL` | J    |Stores pointer to next instruction on the stack, adjusts FP and SP and then `$pc <- $rhi\|$rlo` (`$rs` is not utilized)
F      |`RET`  | J    |Restores FP and stored return address to `$pc` (`$rhi`, `$rlo` and `$rs` are not utlized)

## The Stack

The virtual CPU has a built in stack, which grows downwards towards `0x0000`, accessible through the stack pointer ("SP") (aliased by `$r14`) and the frame pointer ("FP") (aliased by `$r11`).

### Accessing and storing values on the stack

The M-type instructions when `$rhi` is `$r11` or `$r14`, while otherwise undefined, have been overloaded.

Opcode | Name  | Type | Notes
-------|-------| -----| ------
9      |`LOAD` | M    |`$rs <- mem[$rhi + $rlo]` (`$rhi` must be `$r11` or `$r14`)
A      |`STORE`| M    |`$rs -> mem[$rhi + $rlo]` (`$rhi` must be `$r11` or `$r14`)

### Moving the stack pointer

Two R-type instructions: `ADD` and `SUB`, when `$rs` = `$rd` = `$r14`, while otherwise undefined, have been overloaded.

Opcode | Name  | Type | Notes
-------|-------| -----| ------
0      |`ADD`  | R    |`$r14 <- $r14 + $rt`
1      |`SUB`  | R    |`$r14 <- $r14 - $rt`