import pygame
from screens.csv_display_screen import CSVDisplayScreen

class DecodeScreen(CSVDisplayScreen):
    def __init__(self, state):
        super().__init__(state, "decode", origin= "frontend")