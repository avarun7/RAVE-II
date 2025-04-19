import pygame
from screens.csv_display_screen import CSVDisplayScreen

class ArithfuScreen(CSVDisplayScreen):
    def __init__(self, state):
        super().__init__(state, "arithfu", origin= "backend")