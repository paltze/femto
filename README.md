# Femto

Femto is a lean 8-bit CPU emulator. Features:

- 16-bit fixed width instructions
- 16 instructions ISA
- 64 kB memory with a 16-bit memory address bus
- 13 general purpose 8-bit unsigned integer registers

## Usage

Simply compile and execute `main.c`. The emulator loads the given file into the CPU memory, with the very first instruction at location `0x0000` and starts execution.

Since an instruction is 16-bit and the memory is byte addressable, pointers to instruction are stored in pair of memory locations in little-endian format

Edit the path in Line 154 of `src/main.c` to change the program to be loaded into the memory.

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
 - For J type instructions, pointer to the instruction to jump to has to be stored in a pair of registers 

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
9      |`LOAD` | M    |`$rs <- mem[$rhi\|$rlo]`
A      |`STORE`| M    |`$rs -> mem[$rhi\|$rlo]`
B      |`JMP`  | J    |`$pc <- $rhi\|$rlo` (`$rs` is not utilized)
C      |`JZ`   | J    |If `$rs == 0` then `$pc <- $rhi\|$rlo`
D      |`JNZ`  | J    |If `$rs != 0` then `$pc <- $rhi\|$rlo`
E      |`CALL` | J    |Store pointer to next instruction in `$ra` then `$pc <- $rhi\|$rlo` (`$rs` is not utilized)
F      |`RET`  | J    |`$pc <- $ra` (`$rhi`, `$rlo` and `$rs` are not utlized)

## Registers

### General Purpose Registers
`$r0` to `$r12` can be used for computing. These are 8-bit unsigned integer registers

### Special Registers

#### Status Register: `$r13`
Currently, two bits are utlized.

- If the `0x1` bit is set, the last arithmetic operation computed to zero
    - Only `ADD` and `SUB` instructions set this bit when appropriate, all other instructions do not interact with this bit

- If the `0x2` bit is set, the last arithmetic operation either produced a carry, or needed a borrow, whichever is appropriate
    - Only `ADD` and `SUB` instructions set this bit when appropriate, all other instructions do not interact with this bit


#### Stack Pointer Alias: `$r14`

`$r14` is reserved to be an alias to the stack pointer and can be directly manipulated with arithmetic instructions or to access memory

#### Zero Register: `$r15`

`$r15` is reserved as a zero register and should not be modified.
Behavior of writes is undefined.

## Examples

The `program/` directory contains two examples.

- `add.hex`: Load value 10 into registers `$r0` and `$r1`, and store their sum in `$r2`

- `prime.hex`: Primality checker. Load target value in `$r0` in the first instruction. Output a boolean (`1` for prime, `0` for not prime) in `$r2`

## License

This project is licensed under the MIT License. See the LICENSE file for details.
