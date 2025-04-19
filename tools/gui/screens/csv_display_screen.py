import pygame
from .base_screen import BaseScreen
from data_loader import load_csv

class CSVDisplayScreen(BaseScreen):
    def __init__(self, state, label_filter, origin= "frontend"):
        super().__init__()
        self.state = state
        self.label_filter = label_filter.lower()
        self.origin = origin
        self.csv_path = None
        self.back_button = pygame.Rect(50, 700, 100, 40)

    def load_csv_for_screen(self):
        import tkinter as tk
        from tkinter import filedialog

        root = tk.Tk()
        root.withdraw()
        root.attributes('-topmost', True)
        path = filedialog.askopenfilename(filetypes=[("CSV Files", "*.csv")])
        root.destroy()

        if path:
            self.csv_path = path
            self.state.data = load_csv(path)
            self.state.current_cycle = 0

    def update(self, events, state):
        for event in events:
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_l:
                    self.load_csv_for_screen()
                elif event.key == pygame.K_RIGHT:
                    state.current_cycle = min(state.current_cycle + 1, len(state.data) - 1)
                elif event.key == pygame.K_LEFT:
                    state.current_cycle = max(state.current_cycle - 1, 0)
            elif event.type == pygame.MOUSEBUTTONDOWN and event.button == 1:
                if self.back_button.collidepoint(event.pos):
                    if self.origin == "frontend":
                        from .frontend_screen import FrontendScreen
                        state.screen_manager.switch(FrontendScreen(state))
                    elif self.origin == "backend":
                        from .backend_screen import BackendScreen
                        state.screen_manager.switch(BackendScreen(state))

    def draw(self, surface):
        surface.fill((30, 30, 30))
        if self.state.data is None or self.state.data.empty:
            text = self.font.render("No data loaded.", True, (255, 0, 0))
            surface.blit(text, (50, 50))
        else:
            row = self.state.data.iloc[self.state.current_cycle]
            y = 60
            surface.blit(self.font.render(f"Cycle: {self.state.current_cycle}", True, (255, 255, 0)), (50, 20))
            for col, val in row.items():
                if self.label_filter in col.lower():
                    text = self.font.render(f"{col}: {val}", True, (255, 255, 255))
                    surface.blit(text, (50, y))
                    y += 30

        if self.csv_path:
            filename = self.csv_path.split("/")[-1]
            file_text = self.font.render(f"File: {filename}", True, (100, 255, 100))
            surface.blit(file_text, (50, 650))
        elif self.state.csv_path:
            filename = self.state.csv_path.split("/")[-1]
            file_text = self.font.render(f"File (shared): {filename}", True, (180, 180, 180))
            surface.blit(file_text, (50, 650))

        pygame.draw.rect(surface, (80, 80, 80), self.back_button)
        pygame.draw.rect(surface, (255, 255, 255), self.back_button, 2)
        back_text = self.font.render("Back", True, (255, 255, 255))
        surface.blit(back_text, back_text.get_rect(center=self.back_button.center))