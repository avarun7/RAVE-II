# Monitors outputs from the DUT
from pyuvm import *
from cocotb.triggers import Timer

class ProcessorMonitor(uvm_component):
    def build_phase(self):
        self.analysis_port = uvm_analysis_port("analysis_port", self)  # For sending data

    async def run_phase(self):
        while True:
            await Timer(10, "NS")  # Simulate sampling interval (adjust as needed)
            
            # TODO: Replace with actual DUT output capture logic
            dut_output = "mock_output"  # Placeholder, replace with real signal from DUT
            
            self.logger.info(f"Captured DUT output: {dut_output}")
            self.analysis_port.write(dut_output)  # Send output for checking
