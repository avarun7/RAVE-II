import pygame
from screens.csv_display_screen import CSVDisplayScreen

class LdStScreen(CSVDisplayScreen):
    def __init__(self, state):
        super().__init__(state, "ldst", origin= "backend")