import pygame

class BaseScreen:
    def __init__(self):
        self.font = pygame.font.SysFont("Consolas", 20)

    def update(self, events, state):
        pass  # Override in subclass

    def draw(self, surface):
        surface.fill((50, 50, 50))
        message = self.font.render("BaseScreen: Implement draw/update in subclasses", True, (255, 0, 0))
        surface.blit(message, (50, 50))
