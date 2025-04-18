#!/bin/bash

# Check correct inputs
if [ $# -ne 2 ]; then
    echo "Usage: $0 <path_to_compiler_bindir> <source_file.c>"
    exit 1
fi



# Inputs
BINDIR=$1
INPUT_C_FILE=$2

# Check if the file exists
if [ ! -f "$INPUT_C_FILE" ]; then
    echo "Error: File '$INPUT_C_FILE' not found!"
    exit 1
fi

# Extract the base name (without extension)
BASENAME=$(basename "$INPUT_C_FILE" .c)

# Create directory for generated files
mkdir -p "${BASENAME}_asm"
if [ $? -ne 0 ]; then
    echo "Error creating directory!"
    exit 1
fi

# Set up toolchain commands
GCC=$BINDIR/riscv32-unknown-linux-gnu-gcc
OBJDUMP=$BINDIR/riscv32-unknown-linux-gnu-objdump
OBJCOPY=$BINDIR/riscv32-unknown-linux-gnu-objcopy
XXD=xxd

# Compile to object file
echo "Compiling $INPUT_C_FILE to object file..."
$GCC -march=rv32imc -mabi=ilp32 -c -o "${BASENAME}.o" "$INPUT_C_FILE"
if [ $? -ne 0 ]; then
    echo "Error during compilation!"
    exit 1
fi

# Link to ELF executable
echo "Linking to ELF executable..."
$GCC -march=rv32imc -mabi=ilp32 -o "${BASENAME}.elf" "${BASENAME}.o"
if [ $? -ne 0 ]; then
    echo "Error during linking!"
    exit 1
fi

# Generate disassembly dump
echo "Generating disassembly dump..."
$OBJDUMP -d "${BASENAME}.elf" > "${BASENAME}_asm/${BASENAME}.dump"
if [ $? -ne 0 ]; then
    echo "Error generating dump!"
    exit 1
fi

# Convert ELF to raw binary
echo "Converting ELF to raw binary..."
$OBJCOPY -O binary "${BASENAME}.elf" "${BASENAME}_asm/${BASENAME}.bin"
if [ $? -ne 0 ]; then
    echo "Error converting to binary!"
    exit 1
fi

# Convert raw binary to hexadecimal
echo "Generating hexadecimal file..."
$XXD -p "${BASENAME}_asm/${BASENAME}.bin" > "${BASENAME}_asm/${BASENAME}.hex"
if [ $? -ne 0 ]; then
    echo "Error generating hexadecimal file!"
    exit 1
fi

# Clean up intermediate files
mv "${BASENAME}.o" "${BASENAME}_asm/${BASENAME}.o"
mv "${BASENAME}.elf" "${BASENAME}_asm/${BASENAME}.elf"

# Success message
echo "Files generated:"
echo "  - Disassembly: ${BASENAME}_asm/${BASENAME}.dump"
echo "  - Hexadecimal: ${BASENAME}_asm/${BASENAME}.hex"
echo "  - Object:      ${BASENAME}_asm/${BASENAME}.o"
echo "  - ELF:         ${BASENAME}_asm/${BASENAME}.elf"
exit 0
