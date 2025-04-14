class ScreenManager:
    def __init__(self, initial_screen):
        self.current_screen = initial_screen

    def switch(self, new_screen):
        self.current_screen = new_screen

    def update(self, events, state):
        state.screen_manager = self  # Ensure screens have access to switch()
        self.current_screen.update(events, state)

    def draw(self, screen):
        self.current_screen.draw(screen)