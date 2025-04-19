import pygame
from screens.csv_display_screen import CSVDisplayScreen

class MuldivfuScreen(CSVDisplayScreen):
    def __init__(self, state):
        super().__init__(state, "muldiv", origin= "backend")