# Drives inputs to the DUT
import cocotb
from cocotb.triggers import RisingEdge, with_timeout
from pyuvm import *

class ProcessorDriver(uvm_driver):
    def build_phase(self):
        self.last_transaction = None
        self.dut = None

    async def run_phase(self):
        while True:
            transaction = await self.seq_item_port.get_next_item()
            self.logger.info(f"Driving transaction: {transaction}")

            # Store transaction for the monitor
            self.last_transaction = transaction

            # Apply common signals to DUT
            self.dut.rs1.value = transaction.rs1
            self.dut.rs2.value = transaction.rs2
            self.dut.valid_in.value = 1

            # Handle different DUT types
            if "arithmetic_FU" in self.dut._name:
                # Arithmetic FU specific signals
                self.dut.arithmetic_type.value = transaction.arithmetic_type
                if hasattr(self.dut, "additional_info"):
                    self.dut.additional_info.value = transaction.additional_info
            
            elif "logical_FU" in self.dut._name:
                # Logical FU specific signals
                self.dut.logical_type.value = transaction.logical_type
                if hasattr(self.dut, "opcode"):
                    self.dut.opcode.value = transaction.opcode
            
            else:
                self.logger.warning(f"Unknown DUT type: {self.dut._name}, applying generic signals")
                # Try to apply signals that might be common
                if hasattr(self.dut, "opcode"):
                    self.dut.opcode.value = transaction.opcode
                if hasattr(self.dut, "additional_info"):
                    self.dut.additional_info.value = transaction.additional_info
                if hasattr(self.dut, "arithmetic_type"):
                    self.dut.arithmetic_type.value = transaction.arithmetic_type
                if hasattr(self.dut, "logical_type"):
                    self.dut.logical_type.value = transaction.logical_type

            # Wait for one clock cycle
            await RisingEdge(self.dut.clk)
            # # Keep valid_in high for a cycle
            # await RisingEdge(self.dut.clk)
            
            # Set valid_in to 0 after driving
            # self.dut.valid_in.value = 0

            # Wait for valid_out to be asserted (with timeout)
            try:
                await with_timeout(RisingEdge(self.dut.valid_out), 200, "ns")
                self.logger.info(f"Valid output received. Result: {self.dut.result.value}")
                # Now it's safe to clear valid_in after seeing valid_out
                self.dut.valid_in.value = 0
                # Wait one more cycle to let the DUT process the valid_in going low
                await RisingEdge(self.dut.clk)

            except TimeoutError:
                self.logger.error("Timeout waiting for valid_out signal")
                # Clear valid_in even if timeout occurs
                self.dut.valid_in.value = 0
                # Wait one more cycle to let the DUT process the valid_in going low
                await RisingEdge(self.dut.clk)

            self.seq_item_port.item_done()