# -*- coding:utf-8 -*-
import os

theme_basedir = os.path.dirname(__file__) + "/themes"
default_theme = "default"
theme = default_theme

def setThemeBaseDir(_theme_basedir):
    global theme_basedir
    theme_basedir = _theme_basedir

def load():
    global theme
    if os.path.isfile("/etc/wbui/theme"):
        with open("/etc/wbui/theme", "r") as f:
            theme = f.read().strip()
        if theme == "": theme = default_theme

def getDefaultThemeDir():
    return theme_basedir + "/" + default_theme

def getThemeDir(themeName = None):
    return theme_basedir + "/" + (theme if themeName == None else themeName)

def getExisting(filename_list):
    for filename in filename_list:
        if os.path.isfile(filename): return filename
    return None

def getThemeFilePath(filename):
    candidates = []
    if hasattr(filename, "__iter__"):
        for f in filename:
            e = getExisting((os.path.normpath(getThemeDir() + "/" + f), os.path.normpath(getDefaultThemeDir() + "/" + f)))
            if e != None: return e
        # else
        return None
    #else
    return getExisting((os.path.normpath(getThemeDir() + "/" + filename), os.path.normpath(getDefaultThemeDir() + "/" + filename)))

def getAvailableThemeList():
    themes = []
    for theme in os.listdir(theme_basedir):
        if os.path.isdir(getThemeDir(theme)) and not theme.startswith("."):
            themes.append(theme)
    return themes

def setTheme(themeName):
    global theme
    theme = themeName
    if not os.path.isdir("/etc/wbui"):
        if os.path.exists("/etc/wbui"):
            raise Exception("Directory /etc/wbui couldn't be created")
            return
        else:
            os.mkdir("/etc/wbui")
    with open("/etc/wbui/theme", "w") as f:
        f.write(theme)

def getTheme():
    return theme
