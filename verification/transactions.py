from pyuvm import uvm_sequence_item

class ProcessorTransaction(uvm_sequence_item):
    def __init__(self, name="ProcessorTransaction"):
        super().__init__(name)
        self.instruction = ""
    
    def randomize(self):
        import random
        valid_instr = [f"INSTR_{i}" for i in range(5)]
        self.instruction = random.choice(valid_instr)

    def __str__(self):
        return f"Instruction: {self.instruction}"
