# -*- coding:utf-8 -*-

import gui
import gui.list
import resource_loader

window = None

class ListItemBase(gui.list.ListItem):
    def __init__(self, icon, text, font, height, margin_left, data = None):
        gui.list.ListItem.__init__(self, height)
        self.icon = icon
        self.text = font.render(text, True, (0, 0, 0))
        self.data = data
        self.margin_left = margin_left
    def getData(self):
        return self.data
    def paint(self, surface, y):
        surface.blit(self.icon, (self.margin_left, y))
        surface.blit(self.text, (self.margin_left + self.icon.get_width() + 10, y + (self.getHeight() - self.text.get_height()) / 2))

class ListItem(ListItemBase):
    def __init__(self, icon, text, data):
        ListItemBase.__init__(self, icon, text, gui.res.font_mainmenu, 32, 10, data)

class SmallListItem(ListItemBase):
    def __init__(self, icon, text, data):
        ListItemBase.__init__(self, icon, text, gui.res.font_mainmenu_small, 24, 16, data)

class MainMenu(gui.list.List):
    def __init__(self):
        gui.list.List.__init__(self, (gui.res.mainmenu_panel.get_size()))
        self.setBgImage(gui.res.mainmenu_panel)
        self.setMarginTop(20)

    def drawCursor(self, surface, selected, item, y, active):
        cursor_image = gui.res.mainmenu_cursor2 if isinstance(item, SmallListItem) else gui.res.mainmenu_cursor1
        surface.blit(cursor_image, (0, y - (cursor_image.get_height() - item.getHeight()) / 2))

def init():
    global window
    if window != None: return

    gui.res.register("mainmenu_panel", resource_loader.loadImage("mainmenu_panel.png"))
    gui.res.register("mainmenu_cursor1", resource_loader.loadImage("mainmenu_cursor1.png"))
    gui.res.register("mainmenu_cursor2", resource_loader.loadImage("mainmenu_cursor2.png"))
    gui.res.register("font_mainmenu", gui.res.font_system.getFont(18))
    gui.res.register("font_mainmenu_small", gui.res.font_system.getFont(16))

    window = MainMenu()
