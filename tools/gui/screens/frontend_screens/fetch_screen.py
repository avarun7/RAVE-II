import pygame
from screens.csv_display_screen import CSVDisplayScreen

class FetchScreen(CSVDisplayScreen):
    def __init__(self, state):
        super().__init__(state, "fetch", origin= "frontend")