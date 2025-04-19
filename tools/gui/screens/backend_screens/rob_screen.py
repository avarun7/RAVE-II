import pygame
from screens.csv_display_screen import CSVDisplayScreen

class RobScreen(CSVDisplayScreen):
    def __init__(self, state):
        super().__init__(state, "rob", origin= "backend")