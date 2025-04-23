
class ScreenManager:
    def __init__(self, initial_screen):
        self.current_screen = initial_screen

    def switch(self, new_screen):
        self.current_screen = new_screen

    def load_csv_for_screen(self):
        #import tkinter as tk
        #from tkinter import filedialog
        from data_loader import load_csv

        #root = tk.Tk()
        #root.withdraw()
        #root.attributes('-topmost', True)
        #path = filedialog.askopenfilename(filetypes=[("CSV Files", "*.csv")])
        #root.destroy()

        #if path:
        #    self.csv_path = path
        #    self.state.data = load_csv(path)
        #    self.state.current_cycle = 0

    def update(self, events, state):
        state.screen_manager = self  # Ensure screens have access to switch()
        self.current_screen.update(events, state)

    def draw(self, screen):
        self.current_screen.draw(screen)
