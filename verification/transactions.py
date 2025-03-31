from pyuvm import uvm_sequence_item
import random

# Logical and Arithmetic FU
class ProcessorTransaction(uvm_sequence_item):
    def __init__(self, op_type, name="ProcessorTransaction"):
        super().__init__(name)
        self.opcode = 0  # Determine whether it's logical or arithmetic
        self.logical_type = 0  # Logical operation type
        self.arithmetic_type = 0  # Arithmetic operation type
        self.rs1 = 0
        self.rs2 = 0
        self.additional_info = 0
        self.valid_in = 1  # Assume input is valid

        # Set the opcode based on operation type
        if op_type == "arithmetic":
            self.opcode = 0b01101  # Arithmetic opcode
        elif op_type == "logical":
            self.opcode = 0b00000  # Logical opcode
        else:
            raise ValueError("Invalid operation type. Must be 'arithmetic' or 'logical'.")

    def randomize(self):
        # self.opcode = random.choice([0b01101, 0b00000])  #SHOULD NOT BE RANDO

        if self.opcode == 0b01101:  # If it's an arithmetic operation
            self.arithmetic_type = random.choice([0b000, 0b010, 0b011])  # ADD/SUB, SLT, SLTU
            self.additional_info = random.randint(0, 1)  # Used for ADD/SUB
        else:  # Logical operations
            self.logical_type = random.choice([0b100, 0b110, 0b111, 0b001, 0b101])  # XOR, OR, AND, LSHIFT, RSHIFT

        # Ensure signed 32-bit numbers for rs1 and rs2
        self.rs1 = random.randint(-(1 << 31), (1 << 31) - 1)
        self.rs2 = random.randint(-(1 << 31), (1 << 31) - 1)
        
        self.valid_in = 1  # Always valid input

    def __str__(self):
        return (f"Opcode: {bin(self.opcode)}, Logical Type: {bin(self.logical_type)}, "
                f"Arithmetic Type: {bin(self.arithmetic_type)}, RS1: {hex(self.rs1)}, "
                f"RS2: {hex(self.rs2)}, Additional Info: {self.additional_info}, "
                f"Valid: {self.valid_in}")
