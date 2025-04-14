class AppState:
    def __init__(self):
        self.current_cycle = 0
        self.focus = "ALU"
        self.csv_path = None
        self.data = None
        self.screen_manager = None

    def load_new_csv(self, path, loader):
        self.csv_path = path
        self.data = loader(path)
        self.current_cycle = 0