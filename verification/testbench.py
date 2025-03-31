# Top-level test that runs the simulations
import asyncio
from pyuvm import *
from env import ProcessorEnv
from sequences import LogicalSequence, ArithmeticSequence #InstructionSequence 
import cocotb
from cocotb.regression import TestFactory
from cocotb.triggers import Timer
from cocotb.triggers import RisingEdge, with_timeout
from cocotb.clock import Clock

@cocotb.test()
async def check_dut_signals(dut):
    print("Available DUT Signals:", dir(dut))

@cocotb.test()
async def basic_dut_test(dut):
    # Create a clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    #reset
    dut.rst.value = 1
    await Timer(10, units="ns")
    dut.rst.value = 0

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    #set inputs
    dut.valid_in.value = 1  # Ensure valid input signal is high
    dut.arithmetic_type.value = 0  # Set the correct operation type
    dut.rs1.value = 5
    dut.rs2.value = 10
    dut.additional_info.value = 0  # Ensure add operation (if used as a control bit)

    # await Timer(100, units="ns")  # Wait a bit longer for the result to propagate
    # Wait for clock cycles for result to propagate
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    # Now check the result
    print(f"DUT Output: {dut.result.value}")
    assert dut.result.value == 15, f"DUT addition failed! Got {dut.result.value}, expected 15"



@cocotb.test()
async def run_logical_test(dut):
    """Run the logical unit test."""

    # Make sure we're using the logical_FU as the DUT
    if "logical_FU" not in cocotb.top._name:
        cocotb.log.warning("This test requires logical_FU as the DUT")

    # Setup clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset sequence
    dut.rst.value = 1
    await Timer(20, units="ns")
    dut.rst.value = 0
    await Timer(20, units="ns")
    
    # Initialize any required signals that aren't driven by the driver
    if hasattr(dut, "rob_entry_in"):
        dut.rob_entry_in.value = 0
    if hasattr(dut, "dest_tag_in"):
        dut.dest_tag_in.value = 0
    
    # Run UVM test
    await uvm_root().run_test("LogicalTest")

@cocotb.test()
async def run_arithmetic_test(dut):
    """Run the arithmetic unit test."""

    # Make sure we're using the arithmetic_FU as the DUT
    if "arithmetic_FU" not in cocotb.top._name:
        cocotb.log.warning("This test requires arithmetic_FU as the DUT")
        
    # Setup clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset sequence
    dut.rst.value = 1
    await Timer(20, units="ns")
    dut.rst.value = 0
    await Timer(20, units="ns")
    
    # Initialize any required signals that aren't driven by the driver
    if hasattr(dut, "rob_entry_in"):
        dut.rob_entry_in.value = 0
    if hasattr(dut, "dest_tag_in"):
        dut.dest_tag_in.value = 0
    
    # Run UVM test
    await uvm_root().run_test("ArithmeticTest")


class LogicalTest(uvm_test):
    def build_phase(self):
        self.env = ProcessorEnv("env", self)

    async def run_phase(self):
        self.raise_objection()
        sequence = LogicalSequence("LogicalSequence")
        await sequence.start(self.env.agent.sequencer)
        self.drop_objection()


class ArithmeticTest(uvm_test):
    def build_phase(self):
        self.env = ProcessorEnv("env", self)

    async def run_phase(self):
        self.raise_objection()
        sequence = ArithmeticSequence("ArithmeticSequence")
        await sequence.start(self.env.agent.sequencer)
        self.drop_objection()


if __name__ == "__main__":
    asyncio.run(uvm_root().run_test("ArithmeticTest"))