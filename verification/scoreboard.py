# Verifies outputs
from pyuvm import *
from pyuvm import UVMComponent

class Scoreboard(UVMComponent):
    def __init__(self, name, parent):
        super().__init__(name, parent)
        self.expected = []
        self.actual = []

    def compare(self, expected, actual):
        if expected == actual:
            print("PASS")
        else:
            print(f"FAIL: Expected {expected}, got {actual}")