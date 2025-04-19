import pygame
from .base_screen import BaseScreen
from screens.frontend_screens.fetch_screen import FetchScreen
from screens.frontend_screens.decode_screen import DecodeScreen

class FrontendScreen(BaseScreen):
    def __init__(self, state):
        super().__init__()
        self.state = state
        self.back_button = pygame.Rect(50, 700, 100, 40)
        self.buttons = [
            ("Fetch", pygame.Rect(400, 200, 200, 50), lambda: state.screen_manager.switch(FetchScreen(state))),
            ("Decode", pygame.Rect(400, 270, 200, 50), lambda: state.screen_manager.switch(DecodeScreen(state)))
        ]

    def update(self, events, state):
        for event in events:
            if event.type == pygame.MOUSEBUTTONDOWN and event.button == 1:
                if self.back_button.collidepoint(event.pos):
                    from .main_menu import MainMenuScreen
                    state.screen_manager.switch(MainMenuScreen(state))
                for label, rect, action in self.buttons:
                    if rect.collidepoint(event.pos):
                        action()

    def draw(self, surface):
        surface.fill((20, 60, 20))
        title = self.font.render("Frontend Structure Options", True, (255, 255, 255))
        surface.blit(title, (50, 50))

        for label, rect, _ in self.buttons:
            pygame.draw.rect(surface, (0, 100, 0), rect)
            pygame.draw.rect(surface, (255, 255, 255), rect, 2)
            text = self.font.render(label, True, (255, 255, 255))
            surface.blit(text, text.get_rect(center=rect.center))

        pygame.draw.rect(surface, (80, 80, 80), self.back_button)
        pygame.draw.rect(surface, (255, 255, 255), self.back_button, 2)
        text = self.font.render("Back", True, (255, 255, 255))
        surface.blit(text, text.get_rect(center=self.back_button.center))
