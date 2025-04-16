import pygame
from .base_screen import BaseScreen

class BackendScreen(BaseScreen):
    def __init__(self, state):
        super().__init__()
        self.state = state
        self.back_button = pygame.Rect(50, 700, 100, 40)
        self.alu_button = pygame.Rect(400, 200, 200, 50)

    def update(self, events, state):
        for event in events:
            if event.type == pygame.MOUSEBUTTONDOWN and event.button == 1:
                if self.back_button.collidepoint(event.pos):
                    from .main_menu import MainMenuScreen
                    state.screen_manager.switch(MainMenuScreen(state))
                elif self.alu_button.collidepoint(event.pos):
                    from .alu_screen import ALUScreen
                    state.screen_manager.switch(ALUScreen(state))

    def draw(self, surface):
        surface.fill((20, 20, 60))
        title = self.font.render("Backend Structure Options", True, (255, 255, 255))
        surface.blit(title, (50, 50))

        # ALU button
        pygame.draw.rect(surface, (40, 40, 100), self.alu_button)
        pygame.draw.rect(surface, (255, 255, 255), self.alu_button, 2)
        alu_text = self.font.render("ALU", True, (255, 255, 255))
        surface.blit(alu_text, alu_text.get_rect(center=self.alu_button.center))

        # Back button
        pygame.draw.rect(surface, (80, 80, 80), self.back_button)
        pygame.draw.rect(surface, (255, 255, 255), self.back_button, 2)
        text = self.font.render("Back", True, (255, 255, 255))
        surface.blit(text, text.get_rect(center=self.back_button.center))
