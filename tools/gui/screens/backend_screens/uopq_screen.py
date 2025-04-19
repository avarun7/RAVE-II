import pygame
from screens.csv_display_screen import CSVDisplayScreen

class UopQScreen(CSVDisplayScreen):
    def __init__(self, state):
        super().__init__(state, "uopq", origin= "backend")