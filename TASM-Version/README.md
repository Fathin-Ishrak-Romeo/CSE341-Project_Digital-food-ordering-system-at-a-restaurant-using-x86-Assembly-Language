# TASM-Compatible Restaurant Food Ordering System

An enhanced menu-driven restaurant food ordering system written in 8086 Assembly Language, developed as an additional implementation of the original project.

## Features

- 5 food categories with 15 individual items
- 3 special combo meals
- Multiple orders with quantities from 1 to 99
- Automatic merging of repeated orders
- Update or remove items from the cart
- Itemized billing
- 10% discount on subtotals of Rs. 1000 or more
- 5% demonstration GST applied after discount
- New customer functionality without restarting the program
- 32-bit arithmetic for larger bill totals

## Requirements

- DOSBox
- Turbo Assembler (TASM 2.51)
- Turbo Linker (TLINK)

## Compilation and Execution

Place the Assembly file in the DOSBox working directory.

If necessary, rename `tasm_version.asm` to `TASM_VER.ASM` to comply with DOS 8.3 filenames.

```text
TASM TASM_VER.ASM
TLINK TASM_VER.OBJ
TASM_VER.EXE
```

## Notes

This implementation is designed for the 8086 instruction set and DOS interrupt services.

The 5% GST rate is used for demonstration purposes and should not be treated as a statement of the applicable tax rate.

This implementation is provided as an additional version alongside the original project's source code.

