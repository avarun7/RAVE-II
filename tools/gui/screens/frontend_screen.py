import pygame
from .base_screen import BaseScreen

class FrontendScreen(BaseScreen):
    def __init__(self, state):
        super().__init__()
        self.state = state
        self.back_button = pygame.Rect(50, 700, 100, 40)

    def update(self, events, state):
        for event in events:
            if event.type == pygame.MOUSEBUTTONDOWN and event.button == 1:
                if self.back_button.collidepoint(event.pos):
                    from .main_menu import MainMenuScreen
                    state.screen_manager.switch(MainMenuScreen(state))

    def draw(self, surface):
        surface.fill((20, 60, 20))
        title = self.font.render("Frontend Structure Options", True, (255, 255, 255))
        surface.blit(title, (50, 50))
        pygame.draw.rect(surface, (80, 80, 80), self.back_button)
        pygame.draw.rect(surface, (255, 255, 255), self.back_button, 2)
        text = self.font.render("Back", True, (255, 255, 255))
        surface.blit(text, text.get_rect(center=self.back_button.center))