import pygame
from .base_screen import BaseScreen
from .alu_screen import ALUScreen
from .backend_screen import BackendScreen
from .frontend_screen import FrontendScreen

class MainMenuScreen(BaseScreen):
    def __init__(self, state):
        self.state = state
        self.font = pygame.font.SysFont("Consolas", 30)
        self.background = pygame.image.load("ECEStuff/RAVE-II/tools/gui/assets/menu_background.jpg")

        # Define buttons (label, rect, callback)
        self.buttons = [
            ("Frontend", pygame.Rect(400, 200, 200, 50), lambda: state.screen_manager.switch(FrontendScreen(state))),
            ("Backend", pygame.Rect(400, 270, 200, 50), lambda: state.screen_manager.switch(BackendScreen(state))),
        ]

    def update(self, events, state):
        for event in events:
            if event.type == pygame.MOUSEBUTTONDOWN:
                if event.button == 1:  # Left click
                    for label, rect, action in self.buttons:
                        if rect.collidepoint(event.pos):
                            action()

    def draw(self, surface):
        surface.fill((0,0,0))
        surface.blit(self.background, (0, 0))

        for label, rect, _ in self.buttons:
            pygame.draw.rect(surface, (0, 0, 0), rect)
            pygame.draw.rect(surface, (255, 255, 255), rect, 2)
            text = self.font.render(label, True, (255, 255, 255))
            text_rect = text.get_rect(center=rect.center)
            surface.blit(text, text_rect)