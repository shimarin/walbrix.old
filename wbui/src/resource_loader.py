# -*- coding:utf-8 -*-
import os
import pygame

import system
import theme

# 画像リソースをロードする
def loadImage(filename, compatible_with = None):
    theme_filename = theme.getThemeFilePath(filename)
    img = pygame.image.load(theme_filename)
    return img.convert(compatible_with) if compatible_with != None else img.convert_alpha()

# 音声リソースをロードする
def loadSound(filename):
    if pygame.mixer.get_init() == None: return Silent()
    theme_filename = theme.getThemeFilePath(filename)
    return pygame.mixer.Sound(theme_filename)

# /etc/wb/language に従ってリソースを選択する
def l(resources):
    lang = system.lang()
    if lang in resources: return resources[lang]
    # else
    return resources.values()[0]

# /etc/wb/region に従ってリソースを選択する
def r(resources):
    region = system.region()
    if region in resources: return resources[region]
    # else
    return resources.values()[0]
