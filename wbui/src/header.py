# -*- coding: utf-8 -*-
import datetime

import pygame

import gui
import wbui
import status
import resource_loader
import resource_loader

# string resources

gui.res.register("string_header_month",resource_loader.l({"en":u"Mon", "ja":u"月"}))
gui.res.register("string_header_fire",resource_loader.l({"en":u"Tue", "ja":u"火"}))
gui.res.register("string_header_water",resource_loader.l({"en":u"Wed", "ja":u"水"}))
gui.res.register("string_header_tree",resource_loader.l({"en":u"Thu", "ja":u"木"}))
gui.res.register("string_header_gold",resource_loader.l({"en":u"Fri", "ja":u"金"}))
gui.res.register("string_header_soil",resource_loader.l({"en":u"Sat", "ja":u"土"}))
gui.res.register("string_header_day",resource_loader.l({"en":u"Sun", "ja":u"日"}))


counter = 0
d = None
digits = []
ymdcolonblank = []
weekday = []
weekdaystr = [gui.res.string_header_month, gui.res.string_header_fire, gui.res.string_header_water, gui.res.string_header_tree, gui.res.string_header_gold, gui.res.string_header_soil, gui.res.string_header_day]

window = None

class Header(gui.Entity):
    def __init__(self):
        gui.Entity.__init__(self, gui.res.header.get_size())

    def draw(self, surface):
        surface.blit(gui.res.header, (0, 0))
        surface.blit(gui.res.header_logo, (0, (surface.get_height() - gui.res.header_logo.get_height()) / 2))

        joystick_icon = gui.res.icon_joystick_on if gui.res.joystick != None else gui.res.icon_joystick_off
        sound_icon = gui.res.icon_sound_on if wbui.sound_materials != None else gui.res.icon_sound_off
        connect_icon = gui.res.icon_connected if status.is_connected() else gui.res.icon_disconnected
 
        surface.blit(joystick_icon, (surface.get_width() - 10 - joystick_icon.get_width() - 1 - sound_icon.get_width() - 1 - connect_icon.get_width() - 1, (surface.get_height() - joystick_icon.get_height()) / 2))
        surface.blit(sound_icon, (surface.get_width() - 10 - sound_icon.get_width() - 1 - connect_icon.get_width() - 1, (surface.get_height() - sound_icon.get_height()) / 2))
        surface.blit(connect_icon, (surface.get_width() - 10 - connect_icon.get_width() - 1, (surface.get_height() - connect_icon.get_height()) / 2))  

        # 時計
        global counter, d
        if counter == 0: d = datetime.datetime.today()
        counter += 1
        if counter >= wbui.frame_rate: counter = 0
        clock_image_array = generate_clock_image_array(d)
        clock_image_width = sum(map(lambda x: x.get_width(), clock_image_array))
        render(surface, clock_image_array, surface.get_width() / 2 + clock_image_width / 2, (surface.get_height() - clock_image_array[0].get_height()) / 2)

def init():
    global window
    if window != None: return

    gui.res.register("header", resource_loader.loadImage("header.png"))
    gui.res.register("header_logo", resource_loader.loadImage("header_logo.png"))
    gui.res.register("icon_joystick_on", resource_loader.loadImage("icon_joystick_on.png"))
    gui.res.register("icon_joystick_off", resource_loader.loadImage("icon_joystick_off.png"))
    gui.res.register("icon_sound_on", resource_loader.loadImage("icon_sound_on.png"))
    gui.res.register("icon_sound_off", resource_loader.loadImage("icon_sound_off.png"))
    gui.res.register("icon_connected", resource_loader.loadImage("icon_connected.png"))
    gui.res.register("icon_disconnected", resource_loader.loadImage("icon_disconnected.png"))

    font = gui.res.font_system.getFont(16)
    for n in range(0, 10):
        digits.append(font.render(str(n), True, (255, 255, 255)))
    ymdcolonblank.append(font.render(u"年", True, (255, 255, 255)))
    ymdcolonblank.append(font.render(u"月", True, (255, 255, 255)))
    ymdcolonblank.append(font.render(u"日", True, (255, 255, 255)))
    ymdcolonblank.append(font.render(":", True, (255, 255, 255)))
    ymdcolonblank.append(pygame.Surface((ymdcolonblank[3].get_width(), 1), pygame.SRCALPHA, 32))

    for n in range(0, 7):
        color = (255, 255, 255)
        if n == 5: color = (64, 64, 255)
        if n == 6: color = (255, 64, 64)
        weekday.append(font.render(u"(%s)" % weekdaystr[n], True, color))

    window = Header()

def render(surface, images, xright, y):
    width = 0
    for image in images: width += image.get_width()

    x = xright - width
    for image in images:
        surface.blit(image, (x, y))
        x += image.get_width()

def generate_clock_image_array(d):
    img_array = []
    img_array.append(digits[d.year / 1000])
    img_array.append(digits[d.year % 1000 / 100])
    img_array.append(digits[d.year % 100 / 10])
    img_array.append(digits[d.year % 10])
    img_array.append(ymdcolonblank[0]) # 年
    if d.month > 9: img_array.append(digits[d.month / 10])
    img_array.append(digits[d.month % 10])
    img_array.append(ymdcolonblank[1]) # 月
    if d.day > 9: img_array.append(digits[d.day / 10])
    img_array.append(digits[d.day % 10])
    img_array.append(ymdcolonblank[2]) # 日
    img_array.append(weekday[d.weekday()]) # 曜日
    img_array.append(ymdcolonblank[4]) # blank
    img_array.append(digits[d.hour / 10])
    img_array.append(digits[d.hour % 10])
    img_array.append(ymdcolonblank[3] if counter < wbui.frame_rate / 2 else ymdcolonblank[4]) # :
    img_array.append(digits[d.minute / 10])
    img_array.append(digits[d.minute % 10])
    return img_array

