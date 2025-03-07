from pyuvm import uvm_sequence_item
import random

# class ProcessorTransaction(uvm_sequence_item):
#     def __init__(self, name="ProcessorTransaction"):
#         super().__init__(name)
#         self.opcode = 0
#         self.logical_type = 0
#         self.rs1 = 0
#         self.rs2 = 0
#         self.additional_info = 0

#     def randomize(self):
#         import random
#         self.opcode = random.randint(0, 31)
#         self.logical_type = random.choice([0b100, 0b110, 0b111, 0b001, 0b101])
#         self.rs1 = random.randint(0, 2**32 - 1)
#         self.rs2 = random.randint(0, 2**32 - 1)
#         self.additional_info = random.randint(0, 1)

#     def __str__(self):
#         return (f"Opcode: {self.opcode}, Logical Type: {bin(self.logical_type)}, "
#                 f"RS1: {hex(self.rs1)}, RS2: {hex(self.rs2)}, Additional Info: {self.additional_info}")

class ProcessorTransaction(uvm_sequence_item):
    def __init__(self, name="ProcessorTransaction"):
        super().__init__(name)
        self.opcode = 0
        self.logical_type = 0
        self.rs1 = 0
        self.rs2 = 0
        self.additional_info = 0
        self.valid_in = 1  # Assume input is valid by default

    def randomize(self):
        self.opcode = random.choice([0b01101, 0b00000])  # Example: valid opcodes
        self.logical_type = random.choice([0b100, 0b110, 0b111, 0b001, 0b101])  # XOR, OR, AND, LSHIFT, RSHIFT
        self.rs1 = random.randint(0, (1 << 32) - 1)  # Random 32-bit value
        self.rs2 = random.randint(0, (1 << 32) - 1)  # Random 32-bit value
        self.additional_info = random.choice([0, 1])  # Used for arithmetic vs. logical right shift
        self.valid_in = 1  # Always valid input

    def __str__(self):
        return (f"Opcode: {bin(self.opcode)}, Logical Type: {bin(self.logical_type)}, "
                f"RS1: {hex(self.rs1)}, RS2: {hex(self.rs2)}, Additional Info: {self.additional_info}, "
                f"Valid: {self.valid_in}")
