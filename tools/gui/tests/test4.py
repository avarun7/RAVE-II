import pygame
import sys

# Initialize Pygame
pygame.init()

# Set up the display
WIDTH, HEIGHT = 800, 600
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Background Switcher")

# Load background images
bg_images = [pygame.image.load("bg.jpg"), pygame.image.load("bg2.jpg")]
current_bg = 0

# Button setup
button_color = (70, 130, 180)
button_hover_color = (100, 160, 210)
button_rect = pygame.Rect(WIDTH//2 - 75, HEIGHT - 100, 150, 50)
font = pygame.font.SysFont(None, 36)
button_text = font.render("Switch BG", True, (255, 255, 255))

# Main loop
running = True
while running:
    screen.blit(pygame.transform.scale(bg_images[current_bg], (WIDTH, HEIGHT)), (0, 0))

    mouse_pos = pygame.mouse.get_pos()
    is_hover = button_rect.collidepoint(mouse_pos)
    pygame.draw.rect(screen, button_hover_color if is_hover else button_color, button_rect)
    screen.blit(button_text, (button_rect.x + 10, button_rect.y + 10))

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        elif event.type == pygame.MOUSEBUTTONDOWN:
            if button_rect.collidepoint(event.pos):
                current_bg = 1 - current_bg  # Toggle between 0 and 1

    pygame.display.flip()

pygame.quit()
sys.exit()

