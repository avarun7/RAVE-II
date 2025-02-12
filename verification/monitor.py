# Monitors outputs from the DUT
from pyuvm import *
from pyuvm import UVMComponent

class Monitor(UVMComponent):
    def run_phase(self):
        while True:
            # In real usage, capture outputs from the DUT
            output = "mock_output"
            self.send_output(output)

    def send_output(self, data):
        print(f"Monitoring output: {data}")