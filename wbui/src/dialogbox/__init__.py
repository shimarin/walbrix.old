# -*- coding: utf-8 -*-
import pygame
import gui
import theme
import resource_loader

_init_called = False

gui.res.register("color_dialog_text", pygame.Color(16, 16, 16))
gui.res.register("color_dialog_button_text", pygame.Color(0, 0, 0))
# string resources

gui.res.register("string_dialodbox_canceled",resource_loader.l({"en":u"Cancel", "ja":u"キャンセル"}))

def init():
    global _init_called
    if _init_called: return
    else:
        _init_called = True

    gui.res.register("window_lefttop", resource_loader.loadImage("window_lefttop.png"))
    gui.res.register("window_top", resource_loader.loadImage("window_top.png"))
    gui.res.register("window_righttop", resource_loader.loadImage("window_righttop.png"))

    gui.res.register("window_left", resource_loader.loadImage("window_left.png"))
    gui.res.register("window_right", resource_loader.loadImage("window_right.png"))

    gui.res.register("window_center", resource_loader.loadImage("window_center.png"))

    gui.res.register("window_leftbottom", resource_loader.loadImage("window_leftbottom.png"))
    gui.res.register("window_bottom", resource_loader.loadImage("window_bottom.png"))
    gui.res.register("window_rightbottom", resource_loader.loadImage("window_rightbottom.png"))

    gui.res.register("window_leftbottom2", resource_loader.loadImage("window_leftbottom2.png"))
    gui.res.register("window_bottom2", resource_loader.loadImage("window_bottom2.png"))
    gui.res.register("window_rightbottom2", resource_loader.loadImage("window_rightbottom2.png"))

    gui.res.register("dialog_button_selected", resource_loader.loadImage("dialog_button_selected.png"))
    gui.res.register("dialog_button_notselected", resource_loader.loadImage("dialog_button_notselected.png"))

    gui.res.register("icon_ok", resource_loader.loadImage("icon_ok.png"))
    gui.res.register("icon_cancel", resource_loader.loadImage("icon_cancel.png"))

    gui.res.register("keyboard", resource_loader.loadImage("keyboard.png"))

    gui.res.register("font_dialog_text", gui.res.font_system.getFont(18))
    gui.res.register("font_dialog_button", gui.res.font_system.getFont(16))

class DialogBase(gui.Window):
    def __init__(self, contents_size, frame_type=1):
        BOTTOM_GAP = 12

        self.frame_type = frame_type
        self.contents_size = contents_size
        self.bottom_gap = 0 if frame_type == 1 else BOTTOM_GAP # ボタン付きダイアログの場合ギャップが必要
        (self.leftbottom, self.bottom, self.rightbottom) = (gui.res.window_leftbottom, gui.res.window_bottom, gui.res.window_rightbottom) if frame_type == 1 else (gui.res.window_leftbottom2, gui.res.window_bottom2, gui.res.window_rightbottom2)
        width = gui.res.window_lefttop.get_width() + contents_size[0] + gui.res.window_righttop.get_width()
        height = gui.res.window_lefttop.get_height() + contents_size[1] + self.leftbottom.get_height() + self.bottom_gap
        gui.Window.__init__(self, (width, height))

    def getContentsSize(self):
        return self.contents_size

    def paint(self, surface):
        (width, height) = surface.get_size()
        (leftbottom, bottom, rightbottom) = (self.leftbottom, self.bottom, self.rightbottom)

        # 四隅を描画
        surface.blit(gui.res.window_lefttop, (0, 0))
        surface.blit(gui.res.window_righttop, (width - gui.res.window_righttop.get_width(), 0))
        surface.blit(leftbottom, (0, height - leftbottom.get_height()))
        surface.blit(rightbottom, (width - rightbottom.get_width(), height - rightbottom.get_height()))

        # 上の辺を描画
        dx = width - gui.res.window_lefttop.get_width() - gui.res.window_righttop.get_width()
        x = 0
        while x < dx:
            surface.blit(gui.res.window_top, (gui.res.window_lefttop.get_width() + x, 0), (0,0,min(gui.res.window_top.get_width(), dx - x),gui.res.window_top.get_height()))
            x += gui.res.window_top.get_width()

        # 下の辺を描画
        dx = width - leftbottom.get_width() - rightbottom.get_width()
        x = 0
        while x < dx:
            surface.blit(bottom, (leftbottom.get_width() + x, height - bottom.get_height()), (0,0,min(bottom.get_width(), dx - x), bottom.get_height()))
            x += bottom.get_width()

        # 左の辺を描画
        dy = height - gui.res.window_lefttop.get_height() - leftbottom.get_height()
        y = 0
        while y < dy:
            surface.blit(gui.res.window_left, (0, gui.res.window_lefttop.get_height() + y), (0, 0, gui.res.window_left.get_width(), min(gui.res.window_left.get_height(), dy - y)))
            y += gui.res.window_left.get_height()

        # 右の辺を描画
        dy = height - gui.res.window_righttop.get_height() - rightbottom.get_height()
        y = 0
        while y < dy:
            surface.blit(gui.res.window_right, (width - gui.res.window_right.get_width(), gui.res.window_righttop.get_height() + y), (0, 0, gui.res.window_right.get_width(), min(gui.res.window_right.get_height(), dy - y)))
            y += gui.res.window_right.get_height()

        # 中身を描画
        dx = width - leftbottom.get_width() - rightbottom.get_width()
        dy = height - gui.res.window_lefttop.get_height() - leftbottom.get_height()
        y = 0
        while y < dy:
            x = 0
            while x < dx:
                surface.blit(gui.res.window_center, (gui.res.window_left.get_width() + x, gui.res.window_top.get_height() + y), (0, 0, min(gui.res.window_center.get_width(), dx - x), min(gui.res.window_center.get_height(), dy - y)))
                x += gui.res.window_center.get_width()
            y += gui.res.window_center.get_height()

        self.paint_contents(surface.subsurface((gui.res.window_lefttop.get_width(), gui.res.window_lefttop.get_height(), self.contents_size[0], self.contents_size[1])))

        if self.frame_type != 1:
            self.paint_buttons(surface.subsurface((self.leftbottom.get_width(), gui.res.window_top.get_height() + self.contents_size[1] + self.bottom_gap, self.contents_size[0], self.bottom.get_height())))

    def paint_contents(self, surface):
        pass

    def paint_buttons(self, surface):
        pass

    def getContentsOffset(self):
        return gui.res.window_lefttop.get_size()

    def getButtonsOffset(self):
        return (gui.res.window_left.get_width(), gui.res.window_top.get_height() + self.contents_size[1] + self.bottom_gap)

class DialogButton(gui.Entity):
    def __init__(self, text, icon = None):
        self.text = gui.res.font_dialog_button.render(text, True, gui.res.color_dialog_button_text)
        self.icon = icon
        self.selected = False
        gui.Entity.__init__(self, gui.res.dialog_button_notselected.get_size())
    def setSelected(self, selected):
        self.selected = selected
    def draw(self, surface):
        surface.blit(gui.res.dialog_button_selected if self.selected else gui.res.dialog_button_notselected, (0, 0))
        btn_surface = surface if self.selected else pygame.Surface(surface.get_size(), pygame.SRCALPHA, 32)
        if self.icon != None:
            width = self.text.get_width() + self.icon.get_width()
            origin = (surface.get_width() - width) / 2
            btn_surface.blit(self.icon, (origin, (surface.get_height() - self.icon.get_height()) / 2))
            btn_surface.blit(self.text, (origin + self.icon.get_width() , (surface.get_height() - self.text.get_height()) / 2))
        else:
            btn_surface.blit(self.text, ((surface.get_width() - width) / 2, (surface.get_height() - self.text.get_height()) / 2))

        if not self.selected:
            btn_surface.fill((0, 0, 0, 96), None, pygame.BLEND_RGBA_SUB)
            surface.blit(btn_surface, (0, 0))

class DialogBoxContents(gui.Entity):
    def __init__(self, size):
        gui.Entity.__init__(self, size)
    def renderText(self, text, font = None, color = None):
        TEXT_MAX_WIDTH = 540
        if font == None: font = gui.res.font_dialog_text
        if color == None: color = gui.res.color_dialog_text
        return gui.util.render_font_with_wordwrap(font, TEXT_MAX_WIDTH, text, color)

class MessageContents(DialogBoxContents):
    def __init__(self, text, header_image = None):
        self.text = self.renderText(text)
        self.header_image = header_image
        size = (max(self.text.get_width(), header_image.get_width()), self.text.get_height() + header_image.get_height()) if header_image != None else (self.text.get_width(), self.text.get_height() ) 
        gui.Entity.__init__(self, size)
    def draw(self, surface):
        y = 0
        if self.header_image != None:
            surface.blit(self.header_image, ((surface.get_width() - self.header_image.get_width()) / 2, y))
            y += self.header_image.get_height()
        surface.blit(self.text, (0, y))

class DialogBox(DialogBase, gui.EventHandler):

    @staticmethod
    def OK():
        return [ { "id":"ok", "icon":gui.res.icon_ok, "text":"OK" } ]
    @staticmethod
    def OKCANCEL():
        return [ { "id":"ok", "icon":gui.res.icon_ok, "text":"OK" }, { "id":"cancel", "icon":gui.res.icon_cancel, "text":gui.res.string_dialodbox_canceled} ]

    @staticmethod
    def MESSAGE(text, header_image = None):
        return MessageContents(text, header_image)

    def __init__(self, contents, buttons = None, default = 0):
        self.contents = contents

        BUTTON_GAP = 12

        contents_size = contents.getSize()

        if buttons == None:
            adjusted_size = contents_size
        else:
            self.buttons = buttons
            self.dialog_buttons = {}
            button_width =  gui.res.dialog_button_notselected.get_width()
            total_button_width = button_width * len(buttons) + BUTTON_GAP * (len(buttons) - 1)
            adjusted_size =(max(contents_size[0], total_button_width), contents_size[1])

        DialogBase.__init__(self, adjusted_size, 1 if buttons == None else 2)
        gui.EventHandler.__init__(self)

        self.selected = default
        if buttons == None: return

        buttons_offset = self.getButtonsOffset()
        x = buttons_offset[0] + (self.getContentsSize()[0] - total_button_width) / 2
        i = 0
        for button in self.buttons:
            dialog_button = DialogButton(button["text"], button["icon"] if "icon" in button else None)
            dialog_button.setSelected(default == i)
            self.dialog_buttons[button["id"]] = dialog_button
            self.addChild("dialog_button_" + button["id"], dialog_button, (x,buttons_offset[1] + 10))
            i += 1
            x += button_width + BUTTON_GAP

    def select(self):
        self.setResult(self.buttons[self.selected]["id"])
        return True

    def cancel(self):
        self.setResult(None)
        return True

    def _unselect(self):
        self.dialog_buttons[self.buttons[self.selected]["id"]].setSelected(False)
    def _select(self):
        self.dialog_buttons[self.buttons[self.selected]["id"]].setSelected(True)

    def left(self):
        if self.buttons == None or len(self.buttons) < 2: return False
        if self.selected < 1: return False
        self._unselect()
        self.selected -= 1
        self._select()
        return False

    def right(self):
        if self.buttons == None or len(self.buttons) < 2: return False
        if self.selected >= len(self.buttons) - 1: return False
        self._unselect()
        self.selected += 1
        self._select()
        return False

    def paint_contents(self, surface):
        self.contents.draw(surface)

    def execute(self, desktop = None):
        if desktop == None: desktop = gui.getDesktop()
        with desktop.openDialog(self):
            return gui.eventLoop(self)

