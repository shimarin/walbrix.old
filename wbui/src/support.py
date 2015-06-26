# -*- coding:utf-8 -*-
import pygame
import resource_loader

support = None

def init():
    global support
    support_l_filename = resource_loader.r({
        "in":"support_l_in.png",
        "jp":"support_l_jp.png"})
    support = resource_loader.loadImage(support_l_filename)

def refresh():
    return

def get_canvas():
    return support

def update():
    pass

def is_active():
    return False

