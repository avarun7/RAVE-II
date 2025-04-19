import pygame
from screens.csv_display_screen import CSVDisplayScreen

class OooEngScreen(CSVDisplayScreen):
    def __init__(self, state):
        super().__init__(state, "oooeng", origin= "backend")