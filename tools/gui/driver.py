import pygame
import sys
#import tkinter as tk
#from tkinter import filedialog
from screen_manager import ScreenManager
from screens.main_menu import MainMenuScreen
from data_loader import load_csv
from state import AppState

#tk.Tk().withdraw()
pygame.init()

screen = pygame.display.set_mode((1024, 768))
clock = pygame.time.Clock()

state = AppState()
manager = ScreenManager(MainMenuScreen(state))

running = True
while running:
    events = pygame.event.get()
    for event in events:
        if event.type == pygame.QUIT:
            running = False
    manager.update(events, state)
    manager.draw(screen)

    pygame.display.flip()
    clock.tick(60)

pygame.quit()
sys.exit()