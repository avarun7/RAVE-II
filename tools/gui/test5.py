import pygame
import sys

# Initialize Pygame
pygame.init()

# Window settings
WIDTH, HEIGHT = 600, 400
win = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Scrollable Lorem Ipsum")

# Colors and font
WHITE = (255, 255, 255)
BLACK = (0, 0, 0)
FONT = pygame.font.SysFont("arial", 20)

# Lorem Ipsum repeated
lorem = (
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
    "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. "
    "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. "
    "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. "
    "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
)

# Split into lines to fit the width
def wrap_text(text, font, max_width):
    words = text.split()
    lines = []
    line = ""
    for word in words:
        test_line = line + word + " "
        if font.size(test_line)[0] <= max_width:
            line = test_line
        else:
            lines.append(line.strip())
            line = word + " "
    lines.append(line.strip())
    return lines

# Create multiple lines
lines = wrap_text(lorem * 5, FONT, WIDTH - 40)  # Repeated for scrolling

scroll_offset = 0
line_height = FONT.get_height()
max_scroll = max(0, len(lines) * line_height - HEIGHT + 20)

# Main loop
clock = pygame.time.Clock()
running = True
while running:
    win.fill(WHITE)

    # Event handling
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

        # Scroll with mouse wheel
        if event.type == pygame.MOUSEWHEEL:
            scroll_offset -= event.y * 20
        # Scroll with arrow keys
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_DOWN:
                scroll_offset -= 20
            if event.key == pygame.K_UP:
                scroll_offset += 20

    # Clamp scrolling
    scroll_offset = max(-max_scroll, min(0, scroll_offset))

    # Draw visible lines
    y = 10 + scroll_offset
    for line in lines:
        win.blit(FONT.render(line, True, BLACK), (20, y))
        y += line_height

    pygame.display.flip()
    clock.tick(60)

pygame.quit()
sys.exit()

