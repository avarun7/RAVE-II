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
        if transaction.opcode == 0b01101:  # Arithmetic operations
            if transaction.arithmetic_type == 0b000:  # ADD/SUB
                return transaction.rs1 - transaction.rs2 if transaction.additional_info else transaction.rs1 + transaction.rs2
            elif transaction.arithmetic_type == 0b010:  # SLT (signed) 
                rs1_signed = transaction.rs1 if transaction.rs1 >= 0 else transaction.rs1 - (1 << transaction.rs1.bit_length())
                rs2_signed = transaction.rs2 if transaction.rs2 >= 0 else transaction.rs2 - (1 << transaction.rs2.bit_length())
                return 1 if rs1_signed < rs2_signed else 0
            elif transaction.arithmetic_type == 0b011:  # SLTU (unsigned)
                return 1 if (transaction.rs1 & 0xFFFFFFFF) < (transaction.rs2 & 0xFFFFFFFF) else 0
        else:  # Logical operations
            if transaction.logical_type == 0b100:
                return transaction.rs1 ^ transaction.rs2
            if transaction.logical_type == 0b110:
                return transaction.rs1 | transaction.rs2
            if transaction.logical_type == 0b111:
                return transaction.rs1 & transaction.rs2
            if transaction.logical_type == 0b001:
                return transaction.rs1 << (transaction.rs2 & 0b11111)
            if transaction.logical_type == 0b101:
                if transaction.additional_info:
                    return (transaction.rs1 >> (transaction.rs2 & 0b11111)) if transaction.rs1 >= 0 else (~(~transaction.rs1 >> (transaction.rs2 & 0b11111)))
                return transaction.rs1 >> (transaction.rs2 & 0b11111)
        return 0
