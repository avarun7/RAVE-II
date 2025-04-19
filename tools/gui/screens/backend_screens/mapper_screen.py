import pygame
from screens.csv_display_screen import CSVDisplayScreen

class MapperScreen(CSVDisplayScreen):
    def __init__(self, state):
        super().__init__(state, "mapper", origin= "backend")