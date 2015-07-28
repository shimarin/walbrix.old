# -*- coding: utf-8 -*-
import time,os,re,sys,itertools,multiprocessing,Queue,subprocess

import pygame

import gui,gui.res,gui.list,gui.selectbox,gui.progressbar
import dialogbox.messagebox
import resource_loader

import theme,install,tools

from cli2 import create_install_disk,install as cli_install

wb_version = os.uname()[2].split("-", 1)[0]
efi = os.path.isdir("/sys/firmware/efi")

source_devices = []
existing_systems = []

header = None
marquee = None

# string resources

gui.res.register("string_inst_walbrix_install",resource_loader.l({"en":u"Walbrix %s installer", "ja":u"Walbrix %s インストーラ"}))
gui.res.register("string_inst_exit_off",resource_loader.l({"en":u"Exit the installer and power off the system.", "ja":u"インストーラを終了し、システムの電源を切ります。"}))
gui.res.register("string_inst_installation_desc",resource_loader.l({"en":u"You through the installation of Walbrix. Please select the version that you want to install and press the Enter key. Hard disk where you installed will be erased.", "ja":u"Walbrixのインストールを行います。Enterキーを押してインストールするバージョンを選択してください。インストール先のハードディスクは全て消去されます。"}))
gui.res.register("string_installation_not_done",resource_loader.l({"en":u"installation cannot be done because device could not be found", "ja":u"インストール先として使用できそうなデバイスが見つかりませんでした"}))
gui.res.register("string_install_destination",resource_loader.l({"en":u"Select the install destination", "ja":u"インストール先の選択"}))

gui.res.register("string_inst_tools_",resource_loader.l({"en":u"You can use the various tools.", "ja":u"各種ツールを利用できます。"}))

gui.res.register("string_inst_inatall",resource_loader.l({"en":u"Install", "ja":u"インストール"}))
gui.res.register("string_inst_tool",resource_loader.l({"en":u"Tool", "ja":u"ツール"}))
gui.res.register("string_inst_end_",resource_loader.l({"en":u"End", "ja":u"終了"}))

gui.res.register("string_inst_gui_benchmark",resource_loader.l({"en":u"GUI benchmark", "ja":u"GUIベンチマーク"}))
gui.res.register("string_inst_speed_desc",resource_loader.l({"en":u"Simple to measure the processing speed of this computer.", "ja":u"このコンピュータの処理速度を簡易計測します。"}))
gui.res.register("string_inst_console",resource_loader.l({"en":u"Console", "ja":u"コンソール"}))
gui.res.register("string_linux_console_exit",resource_loader.l({"en":u"Exit to the Linux console.", "ja":u"Linuxコンソールに抜けます。"}))

class Header(gui.Entity):
    def __init__(self):
        self.image = resource_loader.loadImage("header.png")
        gui.Entity.__init__(self, self.image.get_size())
        title_text = gui.res.string_inst_walbrix_install % wb_version
        if efi: title_text += "[EFI]"
        self.text = gui.res.font_header.render(title_text, True, (255, 255, 255))
        self.joystick = resource_loader.loadImage("icon_joystick_on.png") if gui.res.joystick != None else resource_loader.loadImage("icon_joystick_off.png")

    def draw(self, surface):
        surface.blit(self.image, (0, 0))
        surface.blit(self.text, ((surface.get_width() - self.text.get_width()) / 2, (surface.get_height() - self.text.get_height()) / 2))
        surface.blit(self.joystick, (surface.get_width() - 10 - self.joystick.get_width(), (surface.get_height() - self.joystick.get_height()) / 2))

class Marquee(gui.Entity):
    def __init__(self):
        self.image = resource_loader.loadImage("footer.png")
        gui.Entity.__init__(self, self.image.get_size())
        self.font = gui.res.font_marquee
        self.text = None
        self.start_time = None
    def setText(self, text):
        if text == None:
            self.text = None
            return
        self.text = []
        head = 0
        # 30文字ずつレンダリング
        tail = min(30, len(text))
        while head < len(text):
            self.text.append(self.font.render(text[head:tail], True, (255,255,255)))
            head = tail
            tail = min(head + 30, len(text))
        self.start_time = pygame.time.get_ticks()

    def draw(self, surface):
        surface.blit(self.image, (0, 0))
        if self.text == None or self.start_time == None: return
        len = sum(x.get_width() for x in self.text) + surface.get_width()
        dt = pygame.time.get_ticks() - self.start_time
        pos = surface.get_width() - dt / 10 % len
        for text in self.text:
            surface.blit(text, (pos, (surface.get_height() - text.get_height()) / 2))
            pos += text.get_width()

class MainMenu(gui.list.List):
    class ListItemBase(gui.list.ListItem):
        def __init__(self, icon, text, font, height, margin_left, window = None):
            gui.list.ListItem.__init__(self, height)
            self.icon = icon
            self.text = font.render(text, True, (0, 0, 0))
            self.window = window
            self.margin_left = margin_left
        def getWindow(self):
            return self.window
        def paint(self, surface, y):
            surface.blit(self.icon, (self.margin_left, y))
            surface.blit(self.text, (self.margin_left + self.icon.get_width() + 10, y + (self.getHeight() - self.text.get_height()) / 2))

    class ListItem(ListItemBase):
        def __init__(self, icon, text, window=None):
            MainMenu.ListItemBase.__init__(self, icon, text, gui.res.font_mainmenu, 32, 10, window)

    class SmallListItem(ListItemBase):
        def __init__(self, icon, text, window=None):
            MainMenu.ListItemBase.__init__(self, icon, text, gui.res.font_mainmenu_small, 24, 16, window)

    def __init__(self):
        image = resource_loader.loadImage("mainmenu_panel.png")
        self.cursor_image1 = resource_loader.loadImage("mainmenu_cursor1.png")
        self.cursor_image2 = resource_loader.loadImage("mainmenu_cursor2.png")
        gui.list.List.__init__(self, (image.get_size()))
        self.setBgImage(image)
        self.setMarginTop(20)

    def drawCursor(self, surface, selected, item, y, active):
        cursor_image = self.cursor_image2 if isinstance(item, MainMenu.SmallListItem) else self.cursor_image1
        surface.blit(cursor_image, (0, y - (cursor_image.get_height() - item.getHeight()) / 2))

class MainMenuEventHandler(gui.list.ListEventHandler):
    def onChange(self, target):
        selected = target.getSelected()
        if selected == None: return
        contents = selected.getWindow()
        desktop = gui.getDesktop()
        if isinstance(contents, Contents):
            desktop.addChild("contents", contents, (desktop.getWidth() - contents.getWidth(), header.getHeight()), 1)
            marquee.setText(contents.getMarqueeText())
        elif desktop.getChild("contents") != None:
            gui.getDesktop().removeChild("contents")
            marquee.setText(gui.res.string_inst_exit_off)

class Contents:
    def __init__(self, marquee_text):
        self.marquee_text = marquee_text
    def getMarqueeText(self):
        return self.marquee_text

class Install(gui.list.List, Contents, gui.list.ListEventHandler):
    def __init__(self):
        gui.list.List.__init__(self, (gui.res.contents_panel.get_size()))
        Contents.__init__(self, gui.res.string_inst_installation_desc)
        self.setBgImage(gui.res.contents_panel)
        self.setEventHandler(self)
    def setMarquee(self):
        marquee.setText(self.getSelected().getData()[2])
    def onChange(self, target):
        if target.isActive(): self.setMarquee()
    def enterEventLoop(self):
        self.setMarquee()

class Tools(gui.list.List, Contents, gui.list.ListEventHandler):
    def __init__(self):
        gui.list.List.__init__(self, (gui.res.contents_panel.get_size()))
        Contents.__init__(self, gui.res.string_inst_tools_)
        self.setBgImage(gui.res.contents_panel)
        self.setEventHandler(self)
    def setMarquee(self):
        marquee.setText(self.getSelected().getData()[1])
    def onChange(self, target):
        if target.isActive(): self.setMarquee()
    def enterEventLoop(self):
        self.setMarquee()

def get_usable_disks(image, q):
    try:
        image = image or cli_install.detect_install_image()
        usable_disks = create_install_disk.usable_disks(int(cli_install.MINIMUM_DISK_SIZE_IN_GB * 1000000000))
        q.put((usable_disks, image))
    except Exception, e:
        q.put(e)

def start(install_image = None):
    desktop = gui.DesktopWindow(gui.getScreen().get_size(), gui.res.background)
    gui.setDesktop(desktop)

    global header, marquee
    header = Header()
    marquee = Marquee()

    with dialogbox.messagebox.open(u"使用可能なディスクを調査中..."):
        q = multiprocessing.Queue()
        p = multiprocessing.Process(target=get_usable_disks, args=(install_image, q))
        p.start()
        while p.is_alive():
            gui.yieldFrame()
        p.join()
        rst = q.get_nowait()
        if isinstance(rst, Exception): raise rst
        disks, install_image = rst

    mainmenu = MainMenu()
    mme = MainMenuEventHandler()
    mainmenu.setEventHandler(mme)
    install.window = Install()
    tools.window = Tools()

    mainmenu_items = []

    if len(disks) > 0:
        mainmenu_items.append(MainMenu.ListItem(gui.res.icon_install, gui.res.string_inst_inatall, install.window))
    mainmenu_items.append(MainMenu.ListItem(gui.res.icon_tools, gui.res.string_inst_tool, tools.window))

    mainmenu.addItems(mainmenu_items)
    items_height = sum(map(lambda x:x.getHeight(), mainmenu_items))

    mainmenu.addItem(gui.list.Separator(332 - mainmenu.getMarginTop() - items_height))
    mainmenu.addItem(MainMenu.SmallListItem(gui.res.icon_shutdown, gui.res.string_inst_end_))

    for disk in disks:
        install.window.addItem(gui.list.TextListItem("%s %s(%s)" % (disk["vendor"],disk["model"],disk["size_str"]), gui.res.font_select_option, None, None, ("install", disk, u"%s %s(%s, %s)に Walbrixをインストールします" % (disk["vendor"],disk["model"],disk["name"],disk["size_str"]))))

    tools.window.addItem(gui.list.TextListItem(gui.res.string_inst_gui_benchmark, gui.res.font_select_option, None, None, ("benchmark", gui.res.string_inst_speed_desc)))
    tools.window.addItem(gui.list.TextListItem(gui.res.string_inst_console, gui.res.font_select_option, None, None, ("console", gui.res.string_linux_console_exit)))

    desktop.addChild("header", header, (0, 0), -1)
    desktop.addChild("marquee", marquee, (0, gui.getScreen().get_height() - marquee.getHeight()), -1)
    desktop.addChild("mainmenu", mainmenu, (0, header.getHeight()), 1)

    while True:
        mme.onChange(mainmenu)
        while gui.eventLoop(mainmenu) == None: pass
        selected = mainmenu.getSelected().getWindow()
        if selected == None: return False
        mainmenu.keepShowingCursor()
        while True:
            if gui.eventLoop(selected) == None: break
            action = selected.getSelected().getData()
            if action[0] == "install":
                install.run(action[1], install_image)
            elif action[0] == "benchmark":
                if not tools.benchmark_gui(): continue
            elif action[0] == "console":
                if not tools.console(): continue

def main(install_image=None,poweroff_at_exit=False):
    pygame.display.init()
    pygame.font.init()
    pygame.mouse.set_visible(False)
    pygame.joystick.init()

    displayMode = pygame.HWSURFACE|pygame.DOUBLEBUF
    driver = pygame.display.get_driver()
    if driver == "directfb": displayMode = pygame.FULLSCREEN
    elif driver == "fbcon": displayMode |= pygame.FULLSCREEN

    try:
        screen = pygame.display.set_mode((640,480), displayMode)
    except pygame.error, e: # 何らかの理由で失敗した場合、引数全省略でset_modeする
        screen = pygame.display.set_mode()

    clock = pygame.time.Clock()

    joystick = pygame.joystick.Joystick(0) if pygame.joystick.get_count() > 0 else None
    gui.res.register("joystick", joystick)
    if joystick != None: joystick.init()

    gui.setScreen(screen)
    gui.setClock(clock)
    gui.setFrameRate(30)

    fontfile_candidates = [ theme.getThemeFilePath("pfont.ttf"), "/System/Library/Fonts/ヒラギノ角ゴ ProN W3.otf", "/usr/share/fonts/vlgothic/VL-PGothic-Regular.ttf"]
    fontfile = next(itertools.ifilter(lambda x:x is not None and os.path.exists(x), fontfile_candidates), None)
    if fontfile == None: raise Exception("Font file doesn't exist")

    gui.res.register("background", resource_loader.loadImage(["background.png", "background.jpg"], screen))
    gui.res.register("button_ok", resource_loader.loadImage("button_ok.png"))
    gui.res.register("button_cancel", resource_loader.loadImage("button_cancel.png"))
    gui.res.register("list_up_arrow", resource_loader.loadImage("up.png"))
    gui.res.register("list_down_arrow", resource_loader.loadImage("down.png"))
    gui.res.register("contents_panel", resource_loader.loadImage("contents_panel.png"))
    gui.res.register("font_system", gui.FontFactory(fontfile))
    gui.res.register("font_select_option", gui.res.font_system.getFont(22))
    gui.res.register("font_messagebox", gui.res.font_system.getFont(28))
    gui.res.register("font_mainmenu", gui.res.font_system.getFont(18))
    gui.res.register("font_marquee", gui.res.font_mainmenu)
    gui.res.register("font_header", gui.res.font_mainmenu)
    gui.res.register("font_mainmenu_small", gui.res.font_system.getFont(16))
    gui.res.register("icon_install", resource_loader.loadImage("icon_install.png"))
    gui.res.register("icon_upgrade", resource_loader.loadImage("icon_upgrade.png"))
    gui.res.register("icon_tools", resource_loader.loadImage("icon_tools.png"))
    gui.res.register("icon_shutdown", resource_loader.loadImage("icon_shutdown.png"))
    gui.res.register("caution_sign", resource_loader.loadImage("caution_sign.png"))
    dialogbox.init()

    try:
        start(install_image)
    finally:
        pygame.quit()
        if poweroff_at_exit: subprocess.call(["poweroff","-f"])

if __name__ == '__main__':
    main(None,None)
