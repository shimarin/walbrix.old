# -*- coding:utf-8 -*-
from __future__ import print_function

import sys
import pygame
import resource_loader
import gui

# string resources

gui.res.register("string_splash_root_pass",resource_loader.l({"en":u"To continue, you need the password for the root", "ja":u"続けるにはrootのパスワードが必要です"}))
gui.res.register("string_enter_key_start",resource_loader.l({"en":u"Press Enter key", "ja":u"Enterキーで開始します"}))

gui.res.register("string_incorrect_pass",resource_loader.l({"en":u"Password is incorrect", "ja":u"パスワードが間違っています"}))


try:
    import PAM
except ImportError as e:
    print("WARNING: Couldn't import PAM")

import wbui
import theme
import pygamehelper
import system
import gui
import traceback
import dialogbox.inputbox
import resource_loader

def pam_conv(auth, query_list):
    try:
        password = dialogbox.inputbox.PasswordInputBox(gui.res.string_splash_root_pass).execute()
    except Exception as e:
        traceback.print_exc(file=sys.stderr)

    if password == None: password = ""

    return [(password, 0)]

def try_auth():
    pam = PAM.pam()
    pam.start("login")
    pam.set_item(PAM.PAM_USER, "root")
    pam.set_item(PAM.PAM_TTY, "tty1")
    pam.set_item(PAM.PAM_CONV, pam_conv)

    try:
        pam.authenticate()
        pam.acct_mgmt()
    except Exception as e:
        return False
    return True

def main():
    clock = gui.getClock()
    screen = gui.getScreen()

    title = resource_loader.loadImage("title.png")
    title_background = resource_loader.loadImage(("title_background.jpg", "title_background.png"), screen)

    copyright = resource_loader.loadImage("copyright.png")
    for y in range(1,100,10):
        clock.tick(60)
	screen.blit(title_background, title_background.get_rect())
	rotitle = pygame.transform.rotozoom(title, 0, y / 100.0)
	screen.blit(rotitle, (320 - rotitle.get_width() / 2,200 - rotitle.get_height() / 2))
	pygame.display.flip()

    for y in range(0, 120, 10):
        clock.tick(60)
	screen.blit(title_background, title_background.get_rect())
	screen.blit(title, (320 - title.get_width() / 2, 200 - title.get_height() / 2))
	screen.blit(copyright, (400, 510 - y))
	pygame.display.flip()

    # シリアルナンバー表示
    s = system.getSystem()
    hostname_txt = pygamehelper.render_font_with_shadow(gui.res.font_splash_serialno, u"SERIAL#: %s" % (s.getHostname()), (255, 255, 255))
    screen.blit(hostname_txt, (16, 430))
    pygame.display.flip()

    oldbg = screen.copy()

    count = 0
    start_msg = pygamehelper.render_font_with_shadow(gui.res.font_splash_message, gui.res.string_enter_key_start, (255, 255, 255))

    while True:
        clock.tick(8)
	event = pygame.event.poll()
	if gui.isSelectEvent(event): break

	if count == 0:
            screen.blit(start_msg, (screen.get_width() / 2 - start_msg.get_width() / 2, screen.get_height() * 2 / 3 - start_msg.get_height() / 2))
	    pygame.display.update()
	elif count == 6:
            screen.blit(oldbg, (0,0))
	    pygame.display.update()

	count += 1
	if count > 11: count = 0

    wbui.play_sound("click")
    
    background = resource_loader.loadImage(("background.jpg", "background.png"), screen)

    for alpha in reversed(range(0,255,32)):
        clock.tick(60)
	screen.blit(background, background.get_rect())
	oldbg.set_alpha(alpha)
	screen.blit(oldbg, oldbg.get_rect())
	pygame.display.flip()

    try:
        desktop = gui.DesktopWindow(screen.get_size())
        gui.setDesktop(desktop)

        for i in (1,2,3):
            if try_auth(): return True
            else: gui.messagebox.execute(gui.res.string_incorrect_pass, ["ok"], gui.res.color_dialog_negative)
    finally:
        gui.setDesktop(None)

    return False
