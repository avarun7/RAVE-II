# Top-level test that runs the simulations
import asyncio
from pyuvm import *
from env import ProcessorEnv
from sequences import InstructionSequence
import cocotb
from cocotb.regression import TestFactory

# Define your test using Cocotb's test
@cocotb.test()
async def run_processor_test1(dut):
    """Cocotb entry point to run the PyUVM test."""
    uvm_root().run_test("ProcessorTest")  # PyUVM test execution

@cocotb.test()
async def run_processor_test2(dut):
    """Cocotb entry point to run the PyUVM test."""
    uvm_root().run_test("ProcessorTest")  # PyUVM test execution

class ProcessorTest(uvm_test):
    def build_phase(self):
        self.env = ProcessorEnv("env", self)  # Ensure env contains a sequencer/ProcessorAgent

    async def run_phase(self):
        self.raise_objection()
        sequence = InstructionSequence("seq")
        await sequence.start(self.env.agent.sequencer)  # Start on sequencer
        self.drop_objection()

if __name__ == "__main__":
    asyncio.run(uvm_root().run_test("ProcessorTest"))