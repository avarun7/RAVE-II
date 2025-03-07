# Verifies outputs
from pyuvm import *

class ProcessorScoreboard(uvm_component):
    def build_phase(self):
        self.analysis_export = uvm_analysis_export("analysis_export", self)  # Receive monitor data
        self.expected_results = {}  # Store expected results

    def write(self, data):
        transaction, actual_result = data  # Assume monitor sends (transaction, result)
        expected_result = self.compute_expected(transaction)

        if expected_result == actual_result:
            self.logger.info(f"PASSED: {transaction} -> {hex(actual_result)}")
        else:
            self.logger.error(f"FAILED: {transaction} -> Expected: {hex(expected_result)}, Got: {hex(actual_result)}")

    def compute_expected(self, transaction):
        if transaction.opcode == 0b01101:
            return transaction.rs1
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
