import pygame
from .base_screen import BaseScreen
from screens.backend_screens.arithfu_screen import ArithfuScreen
from screens.backend_screens.branchfu_screen import BranchfuScreen
from screens.backend_screens.logicalfu_screen import LogicalfuScreen
from screens.backend_screens.dcache_screen import DcacheScreen
from screens.backend_screens.icache_screen import IcacheScreen
from screens.backend_screens.ldst_screen import LdStScreen
from screens.backend_screens.mapper_screen import MapperScreen
from screens.backend_screens.muldivfu_screen import MuldivfuScreen
from screens.backend_screens.ooo_engine_screen import OooEngScreen
from screens.backend_screens.regfile_screen import RegfileScreen
from screens.backend_screens.rob_screen import RobScreen
from screens.backend_screens.uopq_screen import UopQScreen

class BackendScreen(BaseScreen):
    def __init__(self, state):
        super().__init__()
        self.state = state
        self.back_button = pygame.Rect(50, 700, 100, 40)

        self.buttons = [
            # Functional Units
            ("Arithmetic FU", pygame.Rect(100, 150, 200, 40), lambda: state.screen_manager.switch(ArithfuScreen(state))),
            ("Branch FU",     pygame.Rect(100, 200, 200, 40), lambda: state.screen_manager.switch(BranchfuScreen(state))),
            ("Logical FU",    pygame.Rect(100, 250, 200, 40), lambda: state.screen_manager.switch(LogicalfuScreen(state))),
            ("Mul/Div FU",    pygame.Rect(100, 300, 200, 40), lambda: state.screen_manager.switch(MuldivfuScreen(state))),
            ("Load/Store",    pygame.Rect(100, 350, 200, 40), lambda: state.screen_manager.switch(LdStScreen(state))),

            # Engine / Memory Components
            ("Ooo Engine",    pygame.Rect(350, 150, 200, 40), lambda: state.screen_manager.switch(OooEngScreen(state))),
            ("ROB",           pygame.Rect(350, 200, 200, 40), lambda: state.screen_manager.switch(RobScreen(state))),
            ("Uop Queue",     pygame.Rect(350, 250, 200, 40), lambda: state.screen_manager.switch(UopQScreen(state))),
            ("Mapper",        pygame.Rect(350, 300, 200, 40), lambda: state.screen_manager.switch(MapperScreen(state))),
            ("Reg File",      pygame.Rect(350, 350, 200, 40), lambda: state.screen_manager.switch(RegfileScreen(state))),
            ("D-Cache",       pygame.Rect(350, 400, 200, 40), lambda: state.screen_manager.switch(DcacheScreen(state))),
            ("I-Cache",       pygame.Rect(350, 450, 200, 40), lambda: state.screen_manager.switch(IcacheScreen(state))),
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
        title = self.font.render("Backend Structure Options", True, (255, 255, 255))
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
