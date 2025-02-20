# Top-level test that runs the simulations
import asyncio
from pyuvm import *
from env import ProcessorEnv
from sequences import InstructionSequence

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