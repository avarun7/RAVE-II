# Drives inputs to the DUT
from pyuvm import *

class ProcessorDriver(uvm_driver):
    async def run_phase(self):
        while True:
            transaction = await self.seq_item_port.get_next_item()  # Await the transaction
            self.logger.info(f"Driving transaction: {transaction}")

            # TODO: Apply transaction data to the DUT via DPI, VPI, or direct signal assignment
            # Example placeholder:
            # self.dut.instruction = transaction.instruction
            # self.dut.reg_dst = transaction.reg_dst
            # self.dut.reg_src = transaction.reg_src

            self.seq_item_port.item_done()  # Signal transaction completion
