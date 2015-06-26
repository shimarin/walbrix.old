# -*- coding: utf-8 -*-
import pygame

import gui
import dialogbox

gui.res.register("color_dialog_progressbar", pygame.Color(129,221,251))

class ProgressBarDialog(dialogbox.DialogBase):
    def __init__(self, contents):
        self.contents = contents
        self.progress = 0.0
        dialogbox.DialogBase.__init__(self, contents.getSize(), 2)
    def setProgress(self, progress):
        self.progress = progress
    def paint_contents(self, surface):
        self.contents.draw(surface)
    def paint_buttons(self, surface):
        BAR_TOP = 22
        BAR_HEIGHT = 20
        surface.fill((0, 0, 0, 192), (0, BAR_TOP, surface.get_width(), BAR_HEIGHT), pygame.BLEND_RGBA_SUB)
        if self.progress > 0.0:
            alpha = gui.util.get_cycling_value_by_time((64,192), 2000)
            color = (gui.res.color_dialog_progressbar.r, gui.res.color_dialog_progressbar.g, gui.res.color_dialog_progressbar.b, alpha)
            pygame.draw.rect(surface, color, pygame.Rect(0,BAR_TOP,int(surface.get_width() * self.progress), BAR_HEIGHT))

def open(text, header_img = None):
    contents = dialogbox.MessageContents(text, header_img)
    pb = ProgressBarDialog(contents)
    return gui.getDesktop().openDialog(pb)
