# Monitors outputs from the DUT
from pyuvm import *
from cocotb.triggers import Timer

class ProcessorMonitor(uvm_component):
    def build_phase(self):
        self.analysis_port = uvm_analysis_port("analysis_port", self)  

    async def run_phase(self):
        while True:
            await Timer(10, "NS")  # Sampling delay

            # Capture DUT outputs
            actual_result = int(self.dut.result.value)
            valid_out = int(self.dut.valid_out.value)

            if valid_out:
                self.logger.info(f"Captured DUT result: {hex(actual_result)}")
                self.analysis_port.write((self.last_transaction, actual_result))  # Send to scoreboard
