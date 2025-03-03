 # Generates sequences for tests
from pyuvm import *
from transactions import ProcessorTransaction  # Import transaction class

class InstructionSequence(uvm_sequence):
    async def body(self):
        for i in range(5):
            instr_tx = ProcessorTransaction()
            instr_tx.randomize()
            await self.start_item(instr_tx)
            print(f"Generated instruction: {instr_tx}")
            await self.finish_item(instr_tx)
