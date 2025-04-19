import pygame
from screens.csv_display_screen import CSVDisplayScreen

class RegfileScreen(CSVDisplayScreen):
    def __init__(self, state):
        super().__init__(state, "regfile", origin= "backend")