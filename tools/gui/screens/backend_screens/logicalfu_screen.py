import pygame
from screens.csv_display_screen import CSVDisplayScreen

class LogicalfuScreen(CSVDisplayScreen):
    def __init__(self, state):
        super().__init__(state, "logicalfu", origin= "backend")