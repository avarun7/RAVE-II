# Top-level test that runs the simulations
from pyuvm import *
from env import ProcessorEnv
from sequences import InstructionSequence
from pyuvm import UVMTest

class ProcessorTest(UVMTest):
    def build_phase(self):
        self.env = ProcessorEnv("env", self)

    def run_phase(self):
        sequence = InstructionSequence("seq")
        sequence.start(self.env.driver)

if __name__ == "__main__":
    uvm_root().run_test("ProcessorTest")