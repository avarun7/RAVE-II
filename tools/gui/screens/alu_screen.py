import pygame
from .base_screen import BaseScreen

class ALUScreen(BaseScreen):
    def __init__(self, state):
        super().__init__()
        self.state = state
        self.back_button = pygame.Rect(50, 700, 100, 40)

    def update(self, events, state):
        for event in events:
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_RIGHT:
                    state.current_cycle = min(state.current_cycle + 1, len(state.data) - 1)
                elif event.key == pygame.K_LEFT:
                    state.current_cycle = max(state.current_cycle - 1, 0)
            elif event.type == pygame.MOUSEBUTTONDOWN:
                if event.button == 1 and self.back_button.collidepoint(event.pos):
                    from .main_menu import MainMenuScreen  # Lazy import to avoid circular dependency
                    state.screen_manager.switch(MainMenuScreen(state))

    def draw(self, surface):
        surface.fill((20, 20, 20))
        if self.state.data is None or self.state.data.empty:
            text = self.font.render("No data loaded.", True, (255, 0, 0))
            surface.blit(text, (50, 50))
        else:
            row = self.state.data.iloc[self.state.current_cycle]
            y = 60
            surface.blit(self.font.render(f"Cycle: {self.state.current_cycle}", True, (255, 255, 0)), (50, 20))
            for col, val in row.items():
                if "alu" in col.lower():
                    text = self.font.render(f"{col}: {val}", True, (255, 255, 255))
                    surface.blit(text, (50, y))
                    y += 30

        # Draw back button
        pygame.draw.rect(surface, (80, 80, 80), self.back_button)
        pygame.draw.rect(surface, (255, 255, 255), self.back_button, 2)
        back_text = self.font.render("Back", True, (255, 255, 255))
        text_rect = back_text.get_rect(center=self.back_button.center)
        surface.blit(back_text, text_rect)