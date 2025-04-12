import pygame
import sys

# Initialize pygame
pygame.init()

# Set up the display
screen_width = 400
screen_height = 400  # Increased height to make room for the text
screen = pygame.display.set_mode((screen_width, screen_height))
pygame.display.set_caption("Simple GUI with Pygame")

# Define colors
WHITE = (255, 255, 255)
RED = (255, 0, 0)
GREEN = (0, 255, 0)
BLUE = (0, 0, 255)
current_color = WHITE

# Set up fonts
font = pygame.font.SysFont(None, 40)
text_font = pygame.font.SysFont(None, 20)  # Smaller font for text display

# Define button properties
button_width = 150
button_height = 50
button_spacing = 20  # Space between buttons

# Create rectangles for each button
button_rect_red = pygame.Rect((screen_width // 2 - button_width // 2, screen_height // 2 - button_height // 2 - button_spacing), (button_width, button_height))
button_rect_green = pygame.Rect((screen_width // 2 - button_width // 2, screen_height // 2 - button_height // 2 + button_height + button_spacing), (button_width, button_height))
button_rect_blue = pygame.Rect((screen_width // 2 - button_width // 2, screen_height // 2 - button_height // 2 + 2 * (button_height + button_spacing)), (button_width, button_height))

button_color_red = RED
button_color_green = GREEN
button_color_blue = BLUE

# Function to display text
def draw_text(text, x, y, color, font_choice):
    text_surface = font_choice.render(text, True, color)
    screen.blit(text_surface, (x, y))

# Function to read and display the content of the text file
def display_file_content(file_path):
    try:
        with open(file_path, 'r') as file:
            lines = file.readlines()
            return lines
    except FileNotFoundError:
        return ["File not found!"]

# Load content from the text file
file_content = display_file_content("data.txt")

# Initialize variables for text rotation
current_line_index = 0
lines_count = len(file_content)

# Main loop
running = True
while running:
    screen.fill(current_color)  # Fill the screen with the current background color
    
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        if event.type == pygame.MOUSEBUTTONDOWN:
            if button_rect_red.collidepoint(event.pos):
                current_color = RED
                # Update the current line index to rotate the text
                current_line_index = (current_line_index + 1) % lines_count
            elif button_rect_green.collidepoint(event.pos):
                current_color = GREEN
                # Update the current line index to rotate the text
                current_line_index = (current_line_index + 1) % lines_count
            elif button_rect_blue.collidepoint(event.pos):
                current_color = BLUE
                # Update the current line index to rotate the text
                current_line_index = (current_line_index + 1) % lines_count

    # Draw the buttons
    pygame.draw.rect(screen, button_color_red, button_rect_red)
    draw_text("Red", button_rect_red.centerx - 30, button_rect_red.centery - 20, WHITE, font)

    pygame.draw.rect(screen, button_color_green, button_rect_green)
    draw_text("Green", button_rect_green.centerx - 40, button_rect_green.centery - 20, WHITE, font)

    pygame.draw.rect(screen, button_color_blue, button_rect_blue)
    draw_text("Blue", button_rect_blue.centerx - 30, button_rect_blue.centery - 20, WHITE, font)

    # Display the rotating text from the file
    y_offset = 300  # Position to start drawing the text from
    draw_text(file_content[current_line_index].strip(), 20, y_offset, WHITE, text_font)

    pygame.display.update()  # Update the display

# Quit pygame
pygame.quit()
sys.exit()

