# -*- coding:utf-8 -*-
import os
import signal
#import time
import fcntl
import termios

import pygame
import wbui
import gui.messagebox
import resource_loader

canvas = None
console = None
# string resources

gui.res.register("string_console_migration",resource_loader.l({"en":u"Migrate to the Linux console. Do you want?", "ja":u"Linuxのコンソールに移行します。よろしいですか？"}))
#gui.res.register("string_installer_upgrade",resource_loader.l({"en":u"Cancel", "ja":u"キャンセル"}))
#gui.res.register("string_installer_upgrade",resource_loader.l({"en":u"Cancel", "ja":u"キャンセル"}))

def init():
    global canvas, console
    console = resource_loader.loadImage('console_l.png')

def refresh():
    return

def get_canvas():
    return console

def update():
    pass

def is_active():
    return False

def main():
    wbui.play_sound("click")
    if gui.messagebox.execute(gui.res.string_console_migration, ["ok", "cancel"]) != "ok": return

    pygame.quit()

    os.execv("/usr/bin/openvt", ["openvt", "-wsl", "--", "/bin/login", "-f", "root"])
