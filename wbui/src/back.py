# -*- coding:utf-8 -*-
import sys
import urllib2
import subprocess
import threading
import os

import pygame

import wbui
import system
import pygamehelper
import gui
import resource_loader

canvas = None
cursor = None
back = None
alpha = None
dalpha = None
selected = None
active = None
blink_count = None

# string resources


gui.res.register("string_back_title_screen",resource_loader.l({"en":u"Back to the title screen", "ja":u"タイトル画面へ戻る"}))
gui.res.register("string_wbui_exit",resource_loader.l({"en":u"Exit the WBUI", "ja":u"WBUIを終了する"}))



def init():
    global canvas, cursor, back
    canvas = pygame.Surface(gui.res.contents_panel.get_size(), pygame.SRCALPHA, 32)
    cursor = pygame.Surface((canvas.get_width(), wbui.smallfont.get_height()))
    cursor.fill((255,255,128))

    #self.back = main.smallfont.render(u"何もせずにタイトルへ戻る", True, (255,255,255))
    s = system.getSystem()
    back = wbui.smallfont.render(gui.res.string_back_title_screen if s.isRunningAsGetty() else gui.res.string_wbui_exit, True, (255,255,255))
    #self.check_update = main.smallfont.render(u"アップデートをチェックしてから戻る", True, (255, 255, 255))
    #self.show_demo = main.smallfont.render(u"おまけのデモを見てから戻る", True, (255,255,255))

    global alpha, dalpha, selected, active, blink_count
    alpha = 50
    dalpha = 2
    selected = 0
    active = False
    blink_count = 0

def refresh():
    return

def update():
    canvas.fill((0,0,0,0))
    canvas.blit(gui.res.contents_panel, (0, 0))
    # カーソル描画
    global alpha, dalpha, blink_count
    if active:
        cursor.set_alpha(alpha)
        canvas.blit(cursor, (0, selected * cursor.get_height()))
    # コンテンツ描画
    canvas.blit(back, (0, 0))
    #self.canvas.blit(self.check_update, (0, main.smallfont.get_height()))
    #self.canvas.blit(self.show_demo, (0, main.smallfont.get_height() * 2))

    # 上下矢印描画
    if active and blink_count > 15:
        if is_able_to_go_up():
            canvas.blit(wbui.up_arrow, pygamehelper.center_to_lefttop(wbui.up_arrow, (canvas.get_width() / 2, selected * cursor.get_height()) ))
        if is_able_to_go_down():
            canvas.blit(wbui.down_arrow, pygamehelper.center_to_lefttop(wbui.down_arrow, (canvas.get_width() / 2, (selected + 1) * cursor.get_height() - 1)))

    # カーソル点滅
    alpha += dalpha
    if alpha > 127:
        alpha = 127
        dalpha *= -1
    elif alpha < 50:
        alpha = 50
        dalpha *= -1

    # 上下矢印点滅
    blink_count += 1
    if blink_count >= 30:
        blink_count = 0

def get_canvas():
    return canvas

def activate():
    global active
    active = True
    return True

def deactivate():
    global active
    active = False

def is_active():
    return active

def enter():
    if selected == 0:
        pygame.quit()
        sys.exit(0)

def escape():
    return False

def is_able_to_go_up():
    return selected > 0

def is_able_to_go_down():
    #return self.selected < 2
    return False

def up():
    global selected
    if is_able_to_go_up():
        wbui.play_sound("move")
        selected -= 1
        update()
        return True
    return False

def down():
    global selected
    if is_able_to_go_down():
        wbui.play_sound("move")
        selected += 1
        update()
        return True
    return False

