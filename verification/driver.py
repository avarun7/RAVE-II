# Drives inputs to the DUT
from pyuvm import *
from pyuvm import UVMDriver

class Driver(UVMDriver):
    def run_phase(self):
        while True:
            transaction = self.seq_item_port.get_next_item()
            print(f"Driving transaction: {transaction}")
            # Here, you’d apply inputs to the DUT (via DPI or VPI)
            self.seq_item_port.item_done()