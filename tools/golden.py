#!/usr/bin/env python3

import struct
from typing import Dict, List, Tuple
from dataclasses import dataclass
from enum import Enum, auto
import argparse

class Opcode(Enum):
    LOAD = 0b0000011
    STORE = 0b0100011
    BRANCH = 0b1100011
    JAL = 0b1101111
    JALR = 0b1100111
    OP_IMM = 0b0010011
    OP = 0b0110011
    AUIPC = 0b0010111
    LUI = 0b0110111
    SYSTEM = 0b1110011 # for CSRs, ECALL, and EBREAK
    AMO = 0b0101111
    MISC_MEM = 0b0001111  # For FENCE/FENCE.I

class Funct3(Enum):
    # BRANCH
    BEQ = 0b000
    BNE = 0b001
    BLT = 0b100
    BGE = 0b101
    BLTU = 0b110
    BGEU = 0b111
    
    # LOAD
    LB = 0b000
    LH = 0b001
    LW = 0b010
    LBU = 0b100
    LHU = 0b101
    
    # STORE
    SB = 0b000
    SH = 0b001
    SW = 0b010
    
    # OP-IMM & OP
    ADD_SUB = 0b000
    SLL = 0b001
    SLT = 0b010
    SLTU = 0b011
    XOR = 0b100
    SRL_SRA = 0b101
    OR = 0b110
    AND = 0b111

    # MISC-MEM
    FENCE = 0b000
    FENCE_I = 0b001

@dataclass
class CSRState:
    mstatus: int = 0
    mie: int = 0
    mtvec: int = 0
    mscratch: int = 0
    mepc: int = 0
    mcause: int = 0
    mtval: int = 0
    mip: int = 0
    cycle: int = 0
    instret: int = 0

mem_size = 4096

class RV32IMAC:
    def __init__(self):
        self.reset()
        self.verbose = False
        
    def reset(self):
        self.regs = [0] * 32
        self.pc = 0
        self.memory = bytearray(mem_size * mem_size)  # 16 MiB
        self.csr = CSRState()
        self.lr_valid = False
        self.lr_address = 0
        
    def read_mem(self, addr: int, size: int) -> int:
        if size == 1:
            return self.memory[addr]
        elif size == 2:
            return struct.unpack("<H", self.memory[addr:addr+2])[0]
        elif size == 4:
            return struct.unpack("<I", self.memory[addr:addr+4])[0]
        raise ValueError(f"Invalid size: {size}")
    
    def write_mem(self, addr: int, value: int, size: int):
        if size == 1:
            self.memory[addr] = value & 0xFF
        elif size == 2:
            self.memory[addr:addr+2] = struct.pack("<H", value & 0xFFFF)
        elif size == 4:
            self.memory[addr:addr+4] = struct.pack("<I", value & 0xFFFFFFFF)
        else:
            raise ValueError(f"Invalid size: {size}")

    def read_csr(self, addr: int) -> int:
        if addr == 0x300:  # mstatus
            return self.csr.mstatus
        elif addr == 0x304:  # mie
            return self.csr.mie
        elif addr == 0x305:  # mtvec
            return self.csr.mtvec
        elif addr == 0x340:  # mscratch
            return self.csr.mscratch
        elif addr == 0x341:  # mepc
            return self.csr.mepc
        elif addr == 0x342:  # mcause
            return self.csr.mcause
        elif addr == 0x343:  # mtval
            return self.csr.mtval
        elif addr == 0x344:  # mip
            return self.csr.mip
        elif addr == 0xB00:  # mcycle
            return self.csr.cycle
        elif addr == 0xB02:  # minstret
            return self.csr.instret
        raise ValueError(f"Unsupported CSR address: 0x{addr:x}")

    def write_csr(self, addr: int, value: int):
        if addr == 0x300:  # mstatus
            self.csr.mstatus = value
        elif addr == 0x304:  # mie
            self.csr.mie = value
        elif addr == 0x305:  # mtvec
            self.csr.mtvec = value
        elif addr == 0x340:  # mscratch
            self.csr.mscratch = value
        elif addr == 0x341:  # mepc
            self.csr.mepc = value
        elif addr == 0x342:  # mcause
            self.csr.mcause = value
        elif addr == 0x343:  # mtval
            self.csr.mtval = value
        elif addr == 0x344:  # mip
            self.csr.mip = value
        elif addr == 0xB00:  # mcycle
            self.csr.cycle = value
        elif addr == 0xB02:  # minstret
            self.csr.instret = value
        else:
            raise ValueError(f"Unsupported CSR address: 0x{addr:x}")

    def handle_ecall(self):
        self.csr.mcause = 11  # Environment call from M-mode
        self.csr.mepc = self.pc
        self.pc = self.csr.mtvec

    def handle_ebreak(self):
        self.csr.mcause = 3  # Breakpoint
        self.csr.mepc = self.pc
        self.pc = self.csr.mtvec

    def decompress_instruction(self, insn: int) -> int:
        """Decompress RVC instruction to regular instruction"""
        op = insn & 0x3
        funct3 = (insn >> 13) & 0x7
        
        if op == 0b00:
            # C.ADDI4SPN, C.FLD, C.LW, C.FSD, C.SW
            if funct3 == 0b000:  # C.ADDI4SPN
                rd = ((insn >> 2) & 0x7) + 8
                imm = ((insn >> 7) & 0x30) | ((insn >> 1) & 0x3C0) | ((insn >> 4) & 0x4) | ((insn >> 2) & 0x8)
                return (imm << 20) | (2 << 15) | (rd << 7) | 0x13  # addi rd, x2, imm
            elif funct3 == 0b010:  # C.LW
                rd = ((insn >> 2) & 0x7) + 8
                rs1 = ((insn >> 7) & 0x7) + 8
                imm = ((insn >> 4) & 0x4) | ((insn >> 7) & 0x38) | ((insn >> 6) & 0x40)
                return (imm << 20) | (rs1 << 15) | (0b010 << 12) | (rd << 7) | 0x03  # lw rd, imm(rs1)
            
        elif op == 0b01:
            # C.ADDI, C.JAL, C.LI, C.ADDI16SP, C.LUI, C.SRLI, C.SRAI, C.ANDI, C.SUB, C.XOR, C.OR, C.AND
            if funct3 == 0b000:  # C.ADDI
                rd = (insn >> 7) & 0x1F
                imm = ((insn >> 2) & 0x1F) | (((insn >> 12) & 0x1) << 5)
                if imm & 0x20:
                    imm -= 0x40
                return (imm << 20) | (rd << 15) | (0b000 << 12) | (rd << 7) | 0x13  # addi rd, rd, imm
            
        elif op == 0b10:
            # C.SLLI, C.FLDSP, C.LWSP, C.JR, C.MV, C.EBREAK, C.JALR, C.ADD
            if funct3 == 0b100:  # C.JR/C.MV/C.EBREAK/C.JALR/C.ADD
                rd = (insn >> 7) & 0x1F
                rs2 = (insn >> 2) & 0x1F
                if rs2 == 0:  # C.JR/C.JALR
                    return (rd << 15) | 0x67  # jalr x0, rs1, 0
                else:  # C.MV/C.ADD
                    return (0b0000000 << 25) | (rs2 << 20) | (rd << 15) | (0b000 << 12) | (rd << 7) | 0x33  # add rd, rd, rs2
                    
        # Return original instruction if not compressed
        return insn

    def execute_instruction(self, insn: int) -> None:
        # Check if instruction is compressed (16-bit)
        if (insn & 0x3) != 0x3:
            insn = self.decompress_instruction(insn & 0xFFFF)

        opcode = insn & 0x7F
        rd = (insn >> 7) & 0x1F
        funct3 = (insn >> 12) & 0x7
        rs1 = (insn >> 15) & 0x1F
        rs2 = (insn >> 20) & 0x1F
        funct7 = (insn >> 25) & 0x7F
        
        # Decode immediates
        imm_i = (insn >> 20) & 0xFFF
        if imm_i & 0x800:
            imm_i -= 0x1000
            
        imm_s = ((insn >> 25) << 5) | ((insn >> 7) & 0x1F)
        if imm_s & 0x800:
            imm_s -= 0x1000
            
        imm_b = ((insn >> 31) << 12) | ((insn >> 7) & 0x1E) | ((insn >> 20) & 0x7E0)
        if imm_b & 0x1000:
            imm_b -= 0x2000
            
        imm_u = insn & 0xFFFFF000
        
        imm_j = ((insn >> 31) << 20) | ((insn >> 12) & 0xFF000) | ((insn >> 20) & 0x7FE)
        if imm_j & 0x100000:
            imm_j -= 0x200000
        
        next_pc = self.pc + 4
        
        if opcode == Opcode.OP_IMM.value:
            if funct3 == Funct3.ADD_SUB.value:
                self.regs[rd] = self.regs[rs1] + imm_i
            elif funct3 == Funct3.SLT.value:
                self.regs[rd] = 1 if self.regs[rs1] < imm_i else 0
            elif funct3 == Funct3.SLTU.value:
                self.regs[rd] = 1 if (self.regs[rs1] & 0xFFFFFFFF) < (imm_i & 0xFFFFFFFF) else 0
            elif funct3 == Funct3.XOR.value:
                self.regs[rd] = self.regs[rs1] ^ imm_i
            elif funct3 == Funct3.OR.value:
                self.regs[rd] = self.regs[rs1] | imm_i
            elif funct3 == Funct3.AND.value:
                self.regs[rd] = self.regs[rs1] & imm_i
            elif funct3 == Funct3.SLL.value:
                self.regs[rd] = self.regs[rs1] << (imm_i & 0x1F)
            elif funct3 == Funct3.SRL_SRA.value:
                if (imm_i >> 10) & 1:  # SRA
                    self.regs[rd] = self.regs[rs1] >> (imm_i & 0x1F)
                else:  # SRL
                    self.regs[rd] = (self.regs[rs1] & 0xFFFFFFFF) >> (imm_i & 0x1F)
                    
        elif opcode == Opcode.OP.value:
            if funct3 == Funct3.ADD_SUB.value:
                if funct7 & 0x20:  # SUB
                    self.regs[rd] = self.regs[rs1] - self.regs[rs2]
                else:  # ADD
                    self.regs[rd] = self.regs[rs1] + self.regs[rs2]
            elif funct3 == Funct3.SLL.value:
                self.regs[rd] = self.regs[rs1] << (self.regs[rs2] & 0x1F)
            elif funct3 == Funct3.SLT.value:
                self.regs[rd] = 1 if self.regs[rs1] < self.regs[rs2] else 0
            elif funct3 == Funct3.SLTU.value:
                self.regs[rd] = 1 if (self.regs[rs1] & 0xFFFFFFFF) < (self.regs[rs2] & 0xFFFFFFFF) else 0
            elif funct3 == Funct3.XOR.value:
                self.regs[rd] = self.regs[rs1] ^ self.regs[rs2]
            elif funct3 == Funct3.SRL_SRA.value:
                if funct7 & 0x20:  # SRA
                    self.regs[rd] = self.regs[rs1] >> (self.regs[rs2] & 0x1F)
                else:  # SRL
                    self.regs[rd] = (self.regs[rs1] & 0xFFFFFFFF) >> (self.regs[rs2] & 0x1F)
            elif funct3 == Funct3.OR.value:
                self.regs[rd] = self.regs[rs1] | self.regs[rs2]
            elif funct3 == Funct3.AND.value:
                self.regs[rd] = self.regs[rs1] & self.regs[rs2]

        elif opcode == Opcode.LUI.value:
            self.regs[rd] = imm_u

        elif opcode == Opcode.AUIPC.value:
            self.regs[rd] = self.pc + imm_u

        elif opcode == Opcode.JAL.value:
            self.regs[rd] = next_pc
            next_pc = self.pc + imm_j

        elif opcode == Opcode.JALR.value:
            t = next_pc
            next_pc = (self.regs[rs1] + imm_i) & ~1
            self.regs[rd] = t

        elif opcode == Opcode.BRANCH.value:
            if funct3 == Funct3.BEQ.value:
                if self.regs[rs1] == self.regs[rs2]:
                    next_pc = self.pc + imm_b
            elif funct3 == Funct3.BNE.value:
                if self.regs[rs1] != self.regs[rs2]:
                    next_pc = self.pc + imm_b
            elif funct3 == Funct3.BLT.value:
                if self.regs[rs1] < self.regs[rs2]:
                    next_pc = self.pc + imm_b
            elif funct3 == Funct3.BGE.value:
                if self.regs[rs1] >= self.regs[rs2]:
                    next_pc = self.pc + imm_b
            elif funct3 == Funct3.BLTU.value:
                if (self.regs[rs1] & 0xFFFFFFFF) < (self.regs[rs2] & 0xFFFFFFFF):
                    next_pc = self.pc + imm_b
            elif funct3 == Funct3.BGEU.value:
                if (self.regs[rs1] & 0xFFFFFFFF) >= (self.regs[rs2] & 0xFFFFFFFF):
                    next_pc = self.pc + imm_b
        
        elif opcode == Opcode.LOAD.value:
            addr = self.regs[rs1] + imm_i
            if funct3 == Funct3.LB.value:
                self.regs[rd] = self.read_mem(addr, 1)
            elif funct3 == Funct3.LH.value:
                self.regs[rd] = self.read_mem(addr, 2)
            elif funct3 == Funct3.LW.value:
                self.regs[rd] = self.read_mem(addr, 4)
            elif funct3 == Funct3.LBU.value:
                self.regs[rd] = self.read_mem(addr, 1) & 0xFF
            elif funct3 == Funct3.LHU.value:
                self.regs[rd] = self.read_mem(addr, 2) & 0xFFFF
        elif opcode == Opcode.STORE.value:
            addr = self.regs[rs1] + imm_s
            if funct3 == Funct3.SB.value:
                self.write_mem(addr, self.regs[rs2], 1)
            elif funct3 == Funct3.SH.value:
                self.write_mem(addr, self.regs[rs2], 2)
            elif funct3 == Funct3.SW.value:
                self.write_mem(addr, self.regs[rs2], 4)
        elif opcode == Opcode.SYSTEM.value:
            if funct3 == 0b000:
                if self.regs[10] == 93:
                    self.handle_ecall()
                elif self.regs[10] == 111:
                    self.handle_ebreak()
                else:
                    raise ValueError(f"Unsupported SYSTEM instruction: {insn}")
            else:
                raise ValueError(f"Unsupported SYSTEM instruction: {insn}")
        else:
            raise ValueError(f"Unsupported instruction: {insn}")
        
        self.pc = next_pc

    def run(self, program: List[int]) -> None:
        self.reset()
        self.pc = 0x200
        print("verbose = " + str(self.verbose))
        
        # Load each instruction individually into memory
        for i, insn in enumerate(program):
            addr = 0x200 + i * 4
            if addr + 4 > len(self.memory):
                raise ValueError(f"Program too large: instruction at {addr:x} exceeds memory size")
            packed_insn = struct.pack("<I", insn)
            for j in range(4):
                self.memory[addr + j] = packed_insn[j]
        
        #print out the program as seen in memory starting from the PC to the end of the program
        if self.verbose:
            print("Loading program into memory:")
            for i in range(0, len(program)):
                print(f"[0x{self.pc + i * 4:x}]: 0x{program[i]:08x}")
        

        while True:
            if self.verbose:
                print(f"PC: 0x{self.pc:x}")
            if self.pc + 4 > len(self.memory):
                raise ValueError(f"PC {self.pc:x} out of memory bounds")
            
            # Extract the 4 bytes and verify we have them
            mem_slice = self.memory[self.pc:self.pc+4]
            if len(mem_slice) != 4:
                raise ValueError(f"Could not read 4 bytes at PC {self.pc:x}, got {len(mem_slice)} bytes")
            
            insn = struct.unpack("<I", mem_slice)[0]
            if insn != 0 and self.verbose:
                print(f"PC: 0x{self.pc:x}, instruction: 0x{insn:08x}")
            self.execute_instruction(insn)
            if self.pc == 0:
                break



    def dump(self) -> Tuple[List[int], Dict[int, int]]:
        return list(self.regs), {i: self.memory[i] for i in range(0, mem_size, 4) if self.memory[i] != 0}

def parse_instruction_file(filename: str) -> List[int]:
    """Parse a file containing RISC-V instructions in hex format.
    Ignores comments starting with '#'"""
    instructions = []
    with open(filename, 'r') as f:
        for line in f:
            # Remove comments
            line = line.split('#')[0].strip()
            # Skip empty lines
            if not line:
                continue
            # Convert hex string to integer
            try:
                instruction = int(line, 16)
                instructions.append(instruction)
            except ValueError as e:
                print(f"Error parsing instruction: {line}")
                raise e
    return instructions

def run_program(filename: str, verbose: bool = False) -> None:
    """Run a RISC-V program from a file"""
    rv32imac = RV32IMAC()
    rv32imac.verbose = verbose
    
    try:
        instructions = parse_instruction_file(filename)
    except FileNotFoundError:
        print(f"Error: Could not find input file {filename}")
        return
    except ValueError as e:
        print(f"Error parsing instructions: {e}")
        return
        
    try:
        rv32imac.run(instructions)
        regs, mem = rv32imac.dump()
        print("Program finished successfully")
        print("\nRegisters:")
        for i, val in enumerate(regs):
            if val != 0:  # Only print non-zero registers
                print(f"\tx{i}: 0x{val:08x} ({val})")
        print("\nMemory:")
        for addr, val in sorted(mem.items()):
            if val != 0:
                print(f"\t0x{addr:x}: 0x{val:08x} ({val})")
    except Exception as e:
        print(f"Error during program execution: {e}")

def main():
    parser = argparse.ArgumentParser(description="Run RV32IMAC simulator")
    parser.add_argument("--input_file", help="Input file containing RISC-V instructions in hex format", required=True)
    parser.add_argument("--verbose", action="store_true", help="Enable verbose output")
    args = parser.parse_args()

    run_program(args.input_file, args.verbose)

if __name__ == "__main__":
    main()

            

