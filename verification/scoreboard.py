# Verifies outputs
from pyuvm import *

class ProcessorScoreboard(uvm_component):
    def build_phase(self):
        self.analysis_export = uvm_analysis_export("analysis_export", self)  # Receives data from Monitor

    def write(self, data):
        # TODO: Implement logic to compare monitored data with expected values
        self.logger.info(f"Received data in Scoreboard: {data}")
        # For now, just log the received data
