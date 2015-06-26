# -*- coding: utf-8 -*-

import pygame

import gui
import resource_loader

window = None

class Footer(gui.Entity):
    def __init__(self):
        gui.Entity.__init__(self, gui.res.footer.get_size())
        self.font = gui.res.font_marquee
        self.text = None
        self.start_time = None
    def setText(self, text):
        if text == None:
            self.text = None
            return
        self.text = []
        head = 0
        # 30文字ずつレンダリング
        tail = min(30, len(text))
        while head < len(text):
            self.text.append(self.font.render(text[head:tail], True, (255,255,255)))
            head = tail
            tail = min(head + 30, len(text))
        self.start_time = pygame.time.get_ticks()

    def draw(self, surface):
        surface.blit(gui.res.footer, (0, 0))
        if self.text == None or self.start_time == None: return
        len = sum(x.get_width() for x in self.text) + surface.get_width()
        dt = pygame.time.get_ticks() - self.start_time
        pos = surface.get_width() - dt / 10 % len
        for text in self.text:
            surface.blit(text, (pos, (surface.get_height() - text.get_height()) / 2))
            pos += text.get_width()

def init():
    global window
    if window != None: return

    gui.res.register("font_marquee", gui.res.font_system.getFont(18))
    gui.res.register("footer", resource_loader.loadImage("footer.png"))

    window = Footer()
