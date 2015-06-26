# -*- coding:utf-8 -*-
import os
import sys
import pygame

import resource_loader
import system
import pygamehelper
import gui
import dialogbox.messagebox
import resource_loader

# string resources

gui.res.register("string_turnoff_computer",resource_loader.l({"en":u"                            Turn-Off", "ja":u"コンピュータの電源を切る"}))
gui.res.register("string_restart_computer",resource_loader.l({"en":u"                            Restart", "ja":u"システムを再起動する"}))
gui.res.register("string_turnoff_desc",resource_loader.l({"en":u"Turn off the Computer. Are you sure?", "ja":u"コンピュータの電源を切ります。よろしいですか？"}))
gui.res.register("string_restart_desc",resource_loader.l({"en":u"Restart the System.Are you sure?", "ja":u"システムを再起動します。よろしいですか？"}))

window = None

class Window(gui.Window, gui.EventHandler):
    def __init__(self):
        gui.Window.__init__(self, (400, gui.res.shutdown_notselected.get_height() + gui.res.shutdown_selected.get_height() + 12))
        gui.EventHandler.__init__(self)
        self.selected = 0
        font = gui.res.font_system.getFont(18)
        self.shutdown = font.render(gui.res.string_turnoff_computer, True, (255,255,255))
        self.reboot = font.render(gui.res.string_restart_computer, True, (255,255,255))

    def paint(self, surface):
        if not self.isActive():
            img1 = gui.res.shutdown_notselected
            img2 = gui.res.shutdown_notselected
        elif self.selected == 0:
            img1 = gui.res.shutdown_selected
            img2 = gui.res.shutdown_notselected
        else:
            img1 = gui.res.shutdown_notselected
            img2 = gui.res.shutdown_selected

        img1_origin = ((surface.get_width() - img1.get_width()) / 2, 6)
        surface.blit(img1, img1_origin)
        surface.blit(self.shutdown, (img1_origin[0] + 20, img1_origin[1] + (img1.get_height() - self.shutdown.get_height()) / 2))
        img2_origin = ((surface.get_width() - img2.get_width()) / 2, img1.get_height() + 6)
        surface.blit(img2, img2_origin)
        surface.blit(self.reboot, (img2_origin[0] + 20, img2_origin[1] + (img2.get_height() - self.reboot.get_height()) / 2))

    def up(self):
        if self.selected == 1: self.selected = 0
        return False

    def down(self):
        if self.selected == 0: self.selected = 1
        return False

    def select(self):
        self.setResult(self.selected)
        return True

    def cancel(self):
        self.setResult(None)
        return True

def init():
    global window
    if window != None: return

    gui.res.register("shutdown_notselected", resource_loader.loadImage("shutdown_notselected.png"))
    gui.res.register("shutdown_selected", resource_loader.loadImage("shutdown_selected.png"))
    gui.res.register("font_shutdown_text", gui.res.font_system.getFont(20))

    window = Window()

def reboot():
    # utmpが無い場合ramdisk起動（インストーラ）とみなし強制halt
    cmdargs = [ "reboot" ]
    if not os.path.isfile("/var/run/utmp"): cmdargs.append("-f")
    pygame.quit()
    os.execv("/sbin/reboot", cmdargs)
    sys.exit(1)

def poweroff():
    # utmpが無い場合ramdisk起動（インストーラ）とみなし強制halt
    cmdargs = [ "poweroff" ]
    if not os.path.isfile("/var/run/utmp"): cmdargs.append("-f")
    pygame.quit()
    os.execv("/sbin/poweroff", cmdargs)
    sys.exit(1)

def main():
    while True:
        rst = gui.eventLoop(window)
        if rst == None: break
        if rst == 0 and dialogbox.messagebox.execute(gui.res.string_turnoff_desc, dialogbox.DialogBox.OKCANCEL()) == "ok": poweroff()
        elif rst == 1 and dialogbox.messagebox.execute(gui.res.string_restart_desc, dialogbox.DialogBox.OKCANCEL()) == "ok": reboot()



