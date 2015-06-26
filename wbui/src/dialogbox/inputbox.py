# -*- coding:utf-8 -*-
import pygame

import dialogbox
import gui
import gui.util

class TextInputBox(gui.Window, gui.EventHandler):

    CONTENTS_WIDTH = 540

    def __init__(self, label, value = "", min = 1, max = 32, acceptable_chars = "0123456789abcdefghijklmnopqrstuvwxyz-_", password_mode = False):
        
        self.label = gui.Text(gui.res.font_system.getFont(22), (0,0,0))
        self.label.setText(label, TextInputBox.CONTENTS_WIDTH)
        self.value = gui.EditText(gui.res.font_select_option, (0,128,0))
        self.value.setPasswordMode(password_mode)
        self.value.setText(value, TextInputBox.CONTENTS_WIDTH)
        self.value.showCaret(True)
        self.value.setCaretColor((0,0,0))
        if acceptable_chars != None: self.value.setAcceptableChars(acceptable_chars)
        self.dialog = dialogbox.DialogBase((TextInputBox.CONTENTS_WIDTH, self.label.getHeight() + self.value.getHeight() + 8))
        (ox, oy) = self.dialog.getContentsOffset()
        self.dialog.addChild("label", self.label, (ox, oy))
        self.dialog.addChild("value", self.value, (ox, oy + self.label.getHeight() + 8))
        self.keyboard = gui.Bitmap(gui.res.keyboard)

        gui.EventHandler.__init__(self)
        gui.Window.__init__(self, (self.dialog.getWidth(), self.dialog.getHeight() + self.keyboard.getHeight() - 10))
        self.addChild("dialog", self.dialog, (0, 0), 2)
        self.addChild("keyboard", self.keyboard, ((self.getSize()[0] - self.keyboard.getWidth()) / 2, self.dialog.getHeight() - 10), 1)

        self.min = min
        self.max = max

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

class PasswordInputBox(TextInputBox):
    def __init__(self, label, value = "", min = 0, max = 32):
        TextInputBox.__init__(self, label, value, min, max, None, True)
