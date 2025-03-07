# UVM Environment: Integrates components
from pyuvm import *
from monitor import ProcessorMonitor
from scoreboard import ProcessorScoreboard
from driver import ProcessorDriver

class ProcessorAgent(uvm_component):
    def build_phase(self):
        self.sequencer = uvm_sequencer("sequencer", self)
        self.driver = ProcessorDriver("driver", self)

    def connect_phase(self):
        self.driver.seq_item_port.connect(self.sequencer.seq_item_export)  
        self.logger.info("Connected sequencer to driver")

class ProcessorEnv(uvm_component):
    def build_phase(self):
        self.agent = ProcessorAgent("agent", self)  # Agent contains sequencer + driver
        self.monitor = ProcessorMonitor("monitor", self)
        self.scoreboard = ProcessorScoreboard("scoreboard", self)

    def connect_phase(self):
        # Connect the monitor's analysis port to the scoreboard's analysis export
        self.monitor.analysis_port.connect(self.scoreboard.analysis_export)
        self.logger.info("Connected Monitor to Scoreboard")

