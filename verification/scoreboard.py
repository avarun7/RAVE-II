# Verifies outputs
from pyuvm import *

class ProcessorScoreboard(uvm_component):
    def __init__(self, name, parent):
        super().__init__(name, parent)
        self.analysis_fifo = uvm_tlm_analysis_fifo("analysis_fifo", self)
        self.analysis_export = self.analysis_fifo.analysis_export  # Expose the FIFO's export
        self.expected_results = {}  # Store expected results

    def build_phase(self):
        pass

    def connect_phase(self):
        self.get_port = uvm_get_port("get_port", self)
        self.get_port.connect(self.analysis_fifo.get_export)  # Proper FIFO connection

    def check_phase(self):
        while self.get_port.can_get():
            _, data = self.get_port.try_get()

            print(f"Scoreboard received transaction")

            transaction, actual_result = data
            expected_result = self.compute_expected(transaction)

            if expected_result == actual_result:
                self.logger.info(f"PASSED: {transaction} -> {hex(actual_result)}")
            else:
                self.logger.error(f"FAILED: {transaction} -> Expected: {hex(expected_result)}, Got: {hex(actual_result)}")

    def compute_expected(self, transaction):
        def sign_extend(value):
            """Ensures 32-bit signed integer behavior by converting to two's complement if necessary."""
            value &= 0xFFFFFFFF  # Force to 32 bits
            return value if value < 0x80000000 else value - (1 << 32)  # Convert to signed
        
        if transaction.opcode == 0b01101:  # Arithmetic operations
            rs1 = sign_extend(transaction.rs1)
            rs2 = sign_extend(transaction.rs2)

            if transaction.arithmetic_type == 0b000:  # ADD/SUB
                result = rs1 - rs2 if transaction.additional_info else rs1 + rs2
                return result & 0xFFFFFFFF  # Force 32-bit wrapping
            
            elif transaction.arithmetic_type == 0b010:  # SLT (signed)
                return 1 if rs1 < rs2 else 0

            elif transaction.arithmetic_type == 0b011:  # SLTU (unsigned)
                return 1 if (transaction.rs1 & 0xFFFFFFFF) < (transaction.rs2 & 0xFFFFFFFF) else 0
        else:  # Logical operations
            rs1 = transaction.rs1 & 0xFFFFFFFF  # Ensure 32-bit behavior
            rs2 = transaction.rs2 & 0xFFFFFFFF  # Ensure 32-bit behavior

            def logical_right_shift(value, shift):
                """Performs an unsigned right shift (>>> in Verilog)."""
                return (value % (1 << 32)) >> shift  # Ensures logical right shift

            if transaction.logical_type == 0b100:  # XOR
                return rs1 ^ rs2
            
            if transaction.logical_type == 0b110:  # OR
                return rs1 | rs2
            
            if transaction.logical_type == 0b111:  # AND
                return rs1 & rs2
            
            if transaction.logical_type == 0b001:  # Left Shift
                shift_amount = transaction.rs2 & 0b11111  # Mask to 5 bits (0-31)
                return (transaction.rs1 << shift_amount) & 0xFFFFFFFF  # Truncate to 32 bits
            
            if transaction.logical_type == 0b101:  # Right Shift
                if transaction.additional_info:  # Arithmetic shift (sign-extended)
                    return rs1 >> (rs2 & 0b11111)
                else:  # Logical shift
                    return logical_right_shift(rs1, rs2 & 0b11111)
            
            raise ValueError(f"Invalid logical_type: {bin(transaction.logical_type)}")
        return 0
