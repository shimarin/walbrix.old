# -*- coding:utf-8 -*-
import pygame

def loop(screen, white, gray):
    cnt = 0
    clock = pygame.time.Clock()
    while True:
        for event in pygame.event.get():
            if event.type == pygame.QUIT: return
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE: return
        screen.blit(white if cnt % 2 == 0 else gray, (0, 0))
        cnt += 1
        pygame.display.flip()
        clock.tick(30)

if __name__ == '__main__':
    pygame.display.init()
    pygame.joystick.init()
    pygame.font.init()

    displayMode = pygame.HWSURFACE|pygame.DOUBLEBUF
    driver = pygame.display.get_driver()
    if driver == "directfb": displayMode = pygame.FULLSCREEN
    elif driver == "fbcon": displayMode = pygame.FULLSCREEN|pygame.HWSURFACE|pygame.DOUBLEBUF
    elif driver == "x11": pass

    try:
        screen = pygame.display.set_mode((640,480), displayMode)
    except pygame.error, e: # 何らかの理由で失敗した場合、引数全省略でset_modeする
        screen = pygame.display.set_mode()

    pygame.mouse.set_visible(False)

    white = pygame.Surface((640,480))
    white.fill((255,255,255))
    gray = pygame.Surface((640,480))
    gray.fill((128,128,128))

    loop(screen, white, gray)
