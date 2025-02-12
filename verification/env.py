# UVM Environment: Integrates components
from pyuvm import *
from pyuvm import UVMEnv
from env import Driver
from monitor import Monitor
from scoreboard import Scoreboard

class ProcessorEnv(UVMEnv):
    def build_phase(self):
        self.driver = Driver("driver", self)
        self.monitor = Monitor("monitor", self)
        self.scoreboard = Scoreboard("scoreboard", self)
