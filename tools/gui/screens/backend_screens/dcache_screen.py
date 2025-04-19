import pygame
from screens.csv_display_screen import CSVDisplayScreen

class DcacheScreen(CSVDisplayScreen):
    def __init__(self, state):
        super().__init__(state, "dcache", origin= "backend")