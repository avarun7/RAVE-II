 # Generates sequences for tests
from pyuvm import *
from pyuvm import UVMSequence

class InstructionSequence(UVMSequence):
    def body(self):
        for i in range(5):
            instr = f"INSTR_{i}"
            self.start_item(instr)
            print(f"Generated instruction: {instr}")
            self.finish_item(instr)