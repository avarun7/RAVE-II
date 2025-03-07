# Drives inputs to the DUT
import cocotb
from cocotb.triggers import RisingEdge
from pyuvm import *

class ProcessorDriver(uvm_driver):
    async def run_phase(self):
        while True:
            transaction = await self.seq_item_port.get_next_item()
            self.logger.info(f"Driving transaction: {transaction}")

            # Apply transaction to DUT signals
            self.dut.rs1.value = transaction.rs1
            self.dut.rs2.value = transaction.rs2
            self.dut.opcode.value = transaction.opcode
            self.dut.logical_type.value = transaction.logical_type
            self.dut.additional_info.value = transaction.additional_info
            self.dut.valid_in.value = 1

            # Wait for one clock cycle
            await RisingEdge(self.dut.clk)
            
            # Set valid_in to 0 after driving
            self.dut.valid_in.value = 0

            self.seq_item_port.item_done()
