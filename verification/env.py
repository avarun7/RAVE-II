# UVM Environment: Integrates components
from pyuvm import *
from monitor import ProcessorMonitor
from scoreboard import ProcessorScoreboard
from driver import ProcessorDriver
import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock

class DUTWrapper(uvm_component):
    def build_phase(self):
        self.dut = cocotb.top  # Get the DUT from the simulator
        self.logger.info(f"Got DUT in DUTWrapper: {self.dut}")

    def connect_phase(self):
        # Common signals that should be in all modules
        assert hasattr(self.dut, "clk"), "DUT is missing 'clk' signal"
        assert hasattr(self.dut, "rst"), "DUT is missing 'reset' signal"
        assert hasattr(self.dut, "rs1"), "DUT is missing 'rs1' signal"
        assert hasattr(self.dut, "rs2"), "DUT is missing 'rs2' signal"
        assert hasattr(self.dut, "valid_in"), "DUT is missing 'valid_in' signal"
        assert hasattr(self.dut, "result"), "DUT is missing 'result' signal"
        
        # Module-specific signals
        if "logical_FU" in self.dut._name:
            # Logical FU specific signals
            # assert hasattr(self.dut, "opcode"), "DUT is missing 'opcode' signal"
            assert hasattr(self.dut, "logical_type"), "DUT is missing 'logical_type' signal"
            assert hasattr(self.dut, "additional_info"), "DUT is missing 'additional_info' signal"
            self.logger.info("Connected to logical_FU")
        
        elif "arithmetic_FU" in self.dut._name:
            # Arithmetic FU specific signals
            assert hasattr(self.dut, "arithmetic_type"), "DUT is missing 'arithmetic_type' signal"
            assert hasattr(self.dut, "additional_info"), "DUT is missing 'additional_info' signal"
            self.logger.info("Connected to arithmetic_FU")
        
        else:
            self.logger.error(f"Unknown DUT type: {self.dut._name}")

class ProcessorAgent(uvm_component):
    def build_phase(self):
        self.sequencer = uvm_sequencer("sequencer", self)
        self.driver = ProcessorDriver("driver", self)
        self.monitor = ProcessorMonitor("monitor", self, cocotb.top)
        self.scoreboard = ProcessorScoreboard("scoreboard", self)
        self.dut = None

    def connect_phase(self):
        self.driver.seq_item_port.connect(self.sequencer.seq_item_export)  
        print(f"checking multiple Connecting Monitor")
        self.monitor.analysis_port.connect(self.scoreboard.analysis_export)
        self.logger.info("Processor Agent connect phase completed")

class ProcessorEnv(uvm_env):
    def __init__(self, name, parent):
        super().__init__(name, parent)
        self.agent = None
        self.sequencer = None
        # self.scoreboard = None
        self.dut_wrapper = None
        print(f"Instantiating {ProcessorEnv.__name__}")

    def build_phase(self):
        self.agent = ProcessorAgent("agent", self)  # Agent contains sequencer + driver
        self.dut_wrapper = DUTWrapper("dut_wrapper", self)
        # self.scoreboard = ProcessorScoreboard("scoreboard", self)
        self.logger.info("Env init other comps")

    def connect_phase(self):
        # Get DUT from wrapper
        dut = self.dut_wrapper.dut
        
        # Pass DUT to other components
        self.agent.dut = dut
        self.agent.driver.dut = dut
        # self.monitor.dut = dut
        self.logger.info("Passed dut to agent and driver")

    async def start_clock(self, clock_period=10):
        """Start the DUT clock"""
        self.clock = Clock(self.dut_wrapper.dut.clk, clock_period, units="ns")
        cocotb.start_soon(self.clock.start())
        self.logger.info(f"Started clock with period {clock_period}ns")

