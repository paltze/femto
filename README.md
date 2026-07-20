# Femto-8

Femto-8 is an 8-bit virtual CPU

- 16-bit fixed width instructions
- 16 instructions ISA
- 64KB memory with a 16-bit memory address width
- 13 general purpose 8-bit unsigned integer registers

## Usage

Run `make release` to obtain binaries `femto` (the emulator) and `femtoasm` (the assembler). Alternatively, use `make [filename] ARGS='[args]'` to automatically compile and run `src/[filename]`

### `femto`

Following command to execute a Femto-8 Hex binary, as defined in docs:

```
femto path/to/binary.hex
``` 

Optional `-f` flag to print the frequency analysis of the instructions executed

### `femtoasm`

Following command to assemble a Femto-8 ASM program to a Femto-8 Hex binary:

```
femtoasm path/to/assembly.asm path/to/binary.hex
```
## Docs

Find detailed docs on the virtual CPU and Femto-8 ASM and its assembler in `docs/`

## Examples

The `program/` directory contains some example Femto-8 ASM programs

## License

This project is licensed under the MIT License. See the LICENSE file for details.
