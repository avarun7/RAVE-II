# Monitors outputs from the DUT
from pyuvm import *
from cocotb.triggers import Timer, RisingEdge
from scoreboard import ProcessorScoreboard

class ProcessorMonitor(uvm_component):
    def __init__(self, name, parent, dut):
        super().__init__(name, parent)
        self.dut = dut  # Initialize the dut attribute

    def build_phase(self):
        self.analysis_port = uvm_analysis_port("analysis_port", self)
        self.last_transaction = None  

    async def run_phase(self):
        print(f"ProcessorMonitor run_phase started")
        if self.dut is None:
            self.logger.error("DUT is not set in ProcessorMonitor!")
            return
        
        self.last_written_transaction = None  # Track last written transaction

        # while True:
        #     await RisingEdge(self.dut.clk)
        #     print(f"DEBUG: valid_out={self.dut.valid_out.value}")

        while True:
            await RisingEdge(self.dut.clk)

            # Capture transaction driven by the driver
            if hasattr(self.parent.driver, 'last_transaction'):
                self.last_transaction = self.parent.driver.last_transaction

            # Check if valid_out is asserted and ensure we don't write the same transaction multiple times
            if hasattr(self.dut, "valid_out") and str(self.dut.valid_out.value) == "1" and self.last_transaction is not None:
                actual_result = int(self.dut.result.value)

                # Ensure each transaction is written only once
                if self.last_written_transaction != (self.last_transaction, actual_result):
                    # print(f"MONITOR WRITING to scoreboard: {self.last_transaction}, {actual_result}")
                    self.analysis_port.write((self.last_transaction, actual_result))
                    self.last_written_transaction = (self.last_transaction, actual_result)  # Store last written

                self.last_transaction = None  # Clear after use
            else:
                if hasattr(self.dut, "valid_out") and str(self.dut.valid_out.value) == "1":
                    self.logger.warning("Valid output but no transaction captured")