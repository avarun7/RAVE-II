import pygame
from screens.csv_display_screen import CSVDisplayScreen

class IcacheScreen(CSVDisplayScreen):
    def __init__(self, state):
        super().__init__(state, "icache", origin= "backend")