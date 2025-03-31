 # Generates sequences for tests
from pyuvm import *
from transactions import ProcessorTransaction  # Import transaction class
import random

class BaseProcessorSequence(uvm_sequence):
    """Base sequence for processor transactions"""
    def __init__(self, name="BaseProcessorSequence"):
        super().__init__(name)

    async def body(self):
        raise NotImplementedError("Subclasses must implement the body method")


class LogicalSequence(BaseProcessorSequence):
    """Sequence to generate logical operations"""
    def __init__(self, name="LogicalSequence"):
        super().__init__(name)

    async def body(self):
        for _ in range(5):  # Generate multiple transactions
            txn = ProcessorTransaction("logical")
            txn.opcode = 0b00000  # Logical opcode
            txn.logical_type = random.choice([0b100, 0b110, 0b111, 0b001, 0b101])
            txn.rs1 = random.randint(0, (1 << 32) - 1)
            txn.rs2 = random.randint(0, (1 << 32) - 1)
            txn.additional_info = random.randint(0, 1)
            txn.valid_in = 1

            if txn is not None:
                print(f"txn: {txn}")
                await self.start_item(txn)
                print(f"txn: {txn}")

                txn.randomize()
            else:
                print("Transaction is None, cannot randomize.")
            await self.finish_item(txn)


class ArithmeticSequence(BaseProcessorSequence):
    """Sequence to generate arithmetic operations"""
    def __init__(self, name="ArithmeticSequence"):
        super().__init__(name)

    async def body(self):
        for _ in range(5):  # Generate multiple transactions
            txn = ProcessorTransaction("arithmetic")
            txn.opcode = 0b01101  # Arithmetic opcode
            txn.arithmetic_type = random.choice([0b000, 0b010, 0b011])  # ADD/SUB, SLT, SLTU
            txn.rs1 = random.randint(0, (1 << 32) - 1)
            txn.rs2 = random.randint(0, (1 << 32) - 1)
            txn.additional_info = random.randint(0, 1)
            txn.valid_in = 1

            if txn is not None:
                print(f"txn: {txn}")
                await self.start_item(txn)
                print(f"txn: {txn}")

                txn.randomize()
            else:
                print("Transaction is None, cannot randomize.")
            await self.finish_item(txn)
