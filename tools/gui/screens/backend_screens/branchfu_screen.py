import pygame
from screens.csv_display_screen import CSVDisplayScreen

class BranchfuScreen(CSVDisplayScreen):
    def __init__(self, state):
        super().__init__(state, "branchfu", origin= "backend")