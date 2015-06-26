# -*- coding:utf-8 -*-
import pygame
import gui
import gui.util
import resource_loader

class TextInputBox(gui.Window, gui.EventHandler):

    WIDTH = 580

    def __init__(self, label, value = "", bgcolor = None, min = 1, max = 32, acceptable_chars = "0123456789abcdefghijklmnopqrstuvwxyz-_."):
        gui.EventHandler.__init__(self)
        self.keyboard = resource_loader.loadImage("keyboard.png")
        self.label = gui.Text(gui.res.font_messagebox)
        self.label.setText(label, TextInputBox.WIDTH)
        self.value = gui.EditText(gui.res.font_select_option, (96,255,96))
        self.value.setText(value, TextInputBox.WIDTH)
        self.value.showCaret(True)
        self.value.setAcceptableChars(acceptable_chars)
        gui.Window.__init__(self, (TextInputBox.WIDTH + 10, self.label.getHeight() + self.value.getHeight() + 10 + 10 + self.keyboard.get_height()))
        self.bgcolor = bgcolor if bgcolor != None else gui.res.color_dialog_positive
        self.min = min
        self.max = max
        #self.available_chars = available_chars

        self.addChild("label", self.label, (5, 5))
        self.addChild("value", self.value, (5, 5 + self.label.getHeight()))

    def paint(self, surface):
        left = (surface.get_width() - TextInputBox.WIDTH) / 2
        # 枠フィル
        gui.util.draw_filled_round_rect_with_frame(surface, self.bgcolor, gui.res.color_dialog_frame, pygame.Rect(left - 5, 1, TextInputBox.WIDTH + 10, self.label.getHeight() + self.value.getHeight() + 8), 3, 5, 5)
        # キーボード表示
        surface.blit(self.keyboard, (surface.get_width() / 2 - self.keyboard.get_width() / 2, self.label.getHeight() + self.value.getHeight() + 10 + 10))

    def select(self):
        self.setResult(self.value.getText())
        return True

    def cancel(self):
        return True

    def keydown(self, key, unicode):
        self.value.keydown(key, unicode)
        return False

    def execute(self, desktop = None):
        if desktop == None: desktop = gui.getDesktop()
        with desktop.openDialog(self): return gui.eventLoop(self)

