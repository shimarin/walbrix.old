# -*- coding:utf-8 -*-
import os
import sys
import atexit

import pygame
try:
    import alsaaudio
except:
    print >> sys.stderr, "Error: pyalsaaudio not installed"

import header
import footer
import mainmenu
import status
import volume
import domain
import options
import shutdown
import support
import back
import app
import splash

import gui
import gui.list
import gui.messagebox
import util
import catalog
import theme
import system
import pygamehelper
import dialogbox
import resource_loader

# 画像リソース
background = None
messagebox_buttons = {}
left_arrow = None
right_arrow = None
up_arrow = None
down_arrow = None

# フォントリソース
fontfile = None
font = None
smallfont = None
extrasmallfont = None

# 音声リソース
sound_materials = None

# pygameリソース
joystick = None
screen = None
#clock = None

selected = 0
frame_rate = 30

hostname = None
version = None

# string resources
gui.res.register("string_status", resource_loader.l({"en":u"System Status", "ja":u"状態"}))
gui.res.register("string_status_description", resource_loader.l({"en":u"To check the status of the system.Serial number will be required to receive support.In addition, upon receiving a remote support, you must connect to a central server has been established." ,"ja":u"システムの状態を確認します。シリアルナンバーはサポートを受ける際に必要となります。また、遠隔サポートを受ける際には中央サーバへの接続が確立している必要があります。"}))

gui.res.register("string_volume",resource_loader.l({"en":u"Volume","ja":u"領域"}))
gui.res.register("string_volume_description",resource_loader.l({"en":u"Region is storage devices such as hard disks. To create a virtual machine, you must first format the hard disk, to create space." ,"ja":u"領域とは、ハードディスクなどといった記憶装置のことです。仮想マシンを作成するには、まずハードディスクをフォーマットして領域を作成する必要があります。"}))

gui.res.register("string_domain",resource_loader.l({"en":u"Virtual Machines","ja":u"仮想マシン"}))
gui.res.register("string_domain_description",resource_loader.l({"en":u"A virtual machine is a virtual computer that can be invoked in on this computer.You can download the virtual machines of various types depending on the application, you want to create.","ja":u"仮想マシンとは、このコンピュータの中で起動することのできる仮想のコンピュータです。用途に応じて様々な種類の仮想マシンをダウンロードし、作成することが出来ます。"}))

gui.res.register("string_app",resource_loader.l({"en":u"Applications","ja":u"アプリ"}))
gui.res.register("string_app_description",resource_loader.l({"en":u"Add and configure applications and perform start-up." ,"ja":u"アプリケーションの追加や設定、起動を行います。"}))

gui.res.register("string_options",resource_loader.l({"en":u"Options/Tool","ja":u"設定とツール"}))
gui.res.register("string_options_description",resource_loader.l({"en":u"Various settings of the system and set of tools to use.","ja":u"システムの各種設定を行ったり、ツールを利用します。"}))

gui.res.register("string_support",resource_loader.l({"en":u"Support","ja":u"サポート"}))
gui.res.register("string_support_description",resource_loader.l({"en":u"To display information about the support" , "ja":u"サポートについての情報を表示します"}))

gui.res.register("string_back",resource_loader.l({"en":u"Back to Home ","ja":u"タイトルへ戻る"}))
gui.res.register("string_end",resource_loader.l({"en":u"Home ","ja":u"終わり"}))
gui.res.register("string_back_description",resource_loader.l({"en":u"Return to the title screen of the system.By keeping back to the title screen, you can save the power CPU, increase processing performance of the virtual machine." , "ja":u"システムのタイトル画面へ戻ります。タイトル画面へ戻しておくことで、CPU能力を節約し、仮想マシンの処理性能を上げることが出来ます。"}))
gui.res.register("string_back_home_",resource_loader.l({"en":u"Back to Home Screen" , "ja":u"WBUIを終了します"}))

gui.res.register("string_shutdown",resource_loader.l({"en":u"Shutdown","ja":u"システム終了"}))
gui.res.register("string_shutdown_description",resource_loader.l({"en":u"Turning off the computer or restart. That time, all running virtual machines will be stopped on this computer.","ja":u"コンピュータの電源を切ったり、再起動したりします。そのさい、このコンピュータで稼働中の仮想マシンは全て停止されます。"}))


def play_sound(name):
    if sound_materials == None: return
    if name in sound_materials: sound_materials[name].play()

# サブプロセスを全部狩る
def reap_all_subprocesses():
    util.stop_utility()

# wbuiのリスタート
def restart():
    pygame.quit()
    reap_all_subprocesses()
    os.execv("/usr/sbin/wb", ("/usr/sbin/wb", "ui"))

class CoordTransition(gui.Transition):
    def __init__(self, start_from, duration = 250):
        gui.Transition.__init__(self, duration)
        self.start_from = start_from

    def blit(self, src, dest, position):
        dx = position[0] - self.start_from[0]
        dy = position[1] - self.start_from[1]
        dx = dx * self.getPosition()
        dy = dy * self.getPosition()
        new_position = ( self.start_from[0] + dx, self.start_from[1] + dy )
        dest.blit(src, new_position)

def init():
    s = system.getSystem()

    global hostname, version
    hostname = s.getHostname()
    version = system.version

    # 画像リソースのロード
    screen = gui.getScreen()
    global background, left_arrow, right_arrow, up_arrow, down_arrow, contents_color
    background = resource_loader.loadImage(['background.jpg','background.png'], screen)
    gui.res.register("background", background)
    messagebox_buttons["ok"] = resource_loader.loadImage("button_ok.png")
    gui.res.register("button_ok", messagebox_buttons["ok"])
    messagebox_buttons["cancel"] = resource_loader.loadImage("button_cancel.png")
    gui.res.register("button_cancel", messagebox_buttons["cancel"])

    left_arrow = resource_loader.loadImage("left.png")
    gui.res.register("left_arrow", left_arrow)
    right_arrow = resource_loader.loadImage("right.png")
    gui.res.register("right_arrow", right_arrow)
    up_arrow = resource_loader.loadImage("up.png")
    gui.res.register("list_up_arrow", up_arrow)
    down_arrow = resource_loader.loadImage("down.png")
    gui.res.register("list_down_arrow", down_arrow)
    gui.res.register("caution_sign", resource_loader.loadImage("caution_sign.png"))
    gui.res.register("icon_status", resource_loader.loadImage("icon_status.png"))
    gui.res.register("icon_volume", resource_loader.loadImage("icon_volume.png"))
    gui.res.register("icon_domain", resource_loader.loadImage("icon_domain.png"))
    gui.res.register("icon_app", resource_loader.loadImage("icon_app.png"))
    gui.res.register("icon_options", resource_loader.loadImage("icon_options.png"))
    gui.res.register("icon_console", resource_loader.loadImage("icon_console.png"))
    gui.res.register("icon_support", resource_loader.loadImage("icon_support.png"))
    gui.res.register("icon_back", resource_loader.loadImage("icon_back.png"))
    gui.res.register("icon_shutdown", resource_loader.loadImage("icon_shutdown.png"))
    gui.res.register("contents_panel", resource_loader.loadImage("contents_panel.png"))

    # フォントのロード
    global fontfile, font, smallfont, extrasmallfont
    fontfile_candidates = [ theme.getThemeFilePath("pfont.ttf"), "/System/Library/Fonts/ヒラギノ角ゴ ProN W3.otf", "/usr/share/fonts/vlgothic/VL-PGothic-Regular.ttf", "/usr/share/fonts/truetype/takao-gothic/TakaoPGothic.ttf"]
    for fc in fontfile_candidates:
        if fc != None and os.path.exists(fc):
            fontfile = fc
            break

    gui.res.register("font_system", gui.FontFactory(fontfile))

    font = gui.res.font_system.getFont(28)
    smallfont = gui.res.font_system.getFont(22)
    extrasmallfont = gui.res.font_system.getFont(16)
    gui.res.register("font_messagebox", font)
    gui.res.register("font_select_option", smallfont)
    gui.res.register("font_splash_message", font)
    gui.res.register("font_splash_serialno", smallfont)

    # 音声リソースのロード
    if sound_materials != None:
        sound_materials["click"] = resource_loader.loadSound("click.ogg")
        sound_materials["cancel"] = resource_loader.loadSound("cancel.ogg")
        sound_materials["fail"] = resource_loader.loadSound("fail.ogg")
        sound_materials["success"] = resource_loader.loadSound("success.ogg")

    # クロックの初期化
    #global clock
    clock = pygame.time.Clock()
    gui.setClock(clock)

    # initialize dialog box subsystem
    dialogbox.init()

class LegacyContentsWindow(gui.Window, gui.EventHandler):
    def __init__(self, module):
        gui.Window.__init__(self, (400, 409))
        gui.EventHandler.__init__(self)
        self.module = module
    def paint(self, surface):
        if hasattr(self.module, "update"): self.module.update()
        canvas = self.module.get_canvas()
        if canvas != None: surface.blit(canvas, (0, 0))

def set_marquee():
    selected = mainmenu.window.getSelected()
    if selected == None: return
    description = selected.getData()[1]
    footer.window.setText(description)

class MainMenuEventHandler(gui.list.ListEventHandler):
    def __init__(self, desktop):
        self.desktop = desktop
    def onChange(self, target):
        data = target.getSelected().getData()
        selected = data[0]
        if hasattr(selected, "window"):
            self.desktop.addChild("contents", selected.window, (240, header.window.getHeight()), 1)
        else:
            if hasattr(selected, "refresh"): selected.refresh()
            elif hasattr(selected, "update"): selected.update()
            self.desktop.addChild("contents", LegacyContentsWindow(selected), (240, header.window.getHeight()), 1)
        set_marquee()

class SelectedEventHandler(gui.EventHandler):
    def __init__(self, selected):
        gui.EventHandler.__init__(self)
        self.selected = selected

    def select(self):
        self.selected.enter()

    def cancel(self):
        if self.selected.escape() == False:
            play_sound("cancel")
            self.selected.deactivate()
            self.selected.update()
            return True

    def up(self):
        if hasattr(self.selected, "up"): self.selected.up()
    def down(self):
        if hasattr(self.selected, "down"): self.selected.down()
    def right(self):
        if hasattr(self.selected, "right"): self.selected.right()
    def left(self):
        if hasattr(self.selected, "left"): self.selected.left()

def main(skip_splash = False):
    pygame.display.init()

    #display_info = pygame.display.Info()
    # TODO: ゲームコントローラの機種をdetermineしてボタンのリマップを行う
    pygame.joystick.init()
    pygame.font.init()

    global sound_materials
    # http://pyalsaaudio.sourceforge.net/libalsaaudio.html
    volumes = {"Master":50, "PCM":100, "Front":100}
    try:
        for mixer_name in filter(lambda x:x in volumes, alsaaudio.mixers()):
            mixer = alsaaudio.Mixer(mixer_name)
            mixer.setvolume(volumes[mixer_name], alsaaudio.MIXER_CHANNEL_ALL)
    except:
        print >> sys.stderr, "Warning: Mixer doesn't work."

    try:
        pygame.mixer.init() # use default not to harm incompatible devices
        sound_materials = {}
    except:
        print >> sys.stderr, "Warning: Sound device is not available."

    # 物理画面の初期化
    displayMode = pygame.HWSURFACE|pygame.DOUBLEBUF
    driver = pygame.display.get_driver()
    if driver == "directfb": displayMode = pygame.FULLSCREEN
    elif driver == "fbcon": displayMode = pygame.FULLSCREEN|pygame.HWSURFACE|pygame.DOUBLEBUF
    elif driver == "x11": pass

    global screen
    screen = pygame.display.set_mode((640,480), displayMode)
    gui.setScreen(screen)

    # ジョイスティックの検出
    global joystick
    if pygame.joystick.get_count() > 0:
        joystick = pygame.joystick.Joystick(0)
        joystick.init()
    gui.res.register("joystick", joystick) # Noneでも一応registerはする

    # マウスは現在の所非対応
    pygame.mouse.set_visible(False)

    catalog.load()
    theme.load()

    # atexitの登録
    atexit.register(reap_all_subprocesses)

    # 各種リソースのロード
    init()

    # スプラッシュの表示
    if not skip_splash:
        if not splash.main(): return False

    desktop = gui.DesktopWindow(screen.get_size())

    header.init()
    footer.init()

    mainmenu.init()

    status.init()

    volume.init()
    volume.refresh()

    domain.init()
    domain.refresh()

    options.init()
    options.refresh()

    shutdown.init()

    support.init()

    back.init()

    app.init()
    app.refresh()

    mainmenu_items = []
    mainmenu_items.append(mainmenu.ListItem(gui.res.icon_status, gui.res.string_status, (status,gui.res.string_status_description)))
    mainmenu_items.append(mainmenu.ListItem(gui.res.icon_volume, gui.res.string_volume,(volume,gui.res.string_volume_description)))
    mainmenu_items.append(mainmenu.ListItem(gui.res.icon_domain,gui.res.string_domain, (domain,gui.res.string_domain_description)))
    mainmenu_items.append(mainmenu.ListItem(gui.res.icon_app, gui.res.string_app, (app,gui.res.string_app_description)))
    mainmenu_items.append(mainmenu.ListItem(gui.res.icon_options,gui.res.string_options, (options,gui.res.string_options_description)))
    mainmenu_items.append(mainmenu.ListItem(gui.res.icon_support,gui.res.string_support, (support,gui.res.string_support_description)))

    mainmenu.window.addItems(mainmenu_items)

    items_height = sum(map(lambda x:x.getHeight(), mainmenu_items))
    mainmenu.window.addItem(gui.list.Separator(332 - mainmenu.window.getMarginTop() - items_height))
    
    s = system.getSystem()
    mainmenu.window.addItem(mainmenu.SmallListItem(gui.res.icon_back, gui.res.string_back if s.isRunningAsGetty() else gui.res.string_end, (back,gui.res.string_back_description if s.isRunningAsGetty() else gui.res.string_back_home_)))

    mainmenu.window.addItem(mainmenu.SmallListItem(gui.res.icon_shutdown,gui.res.string_shutdown , (shutdown,gui.res.string_shutdown_description)))

    desktop.addChild("header", header.window, (0, 0), -1, CoordTransition((0, -header.window.getHeight())) )
    desktop.addChild("footer", footer.window, (0, desktop.getHeight()-footer.window.getHeight()), -1, CoordTransition((0, desktop.getHeight()) ))
    desktop.addChild("mainmenu", mainmenu.window, (0, header.window.getHeight()), 1,  CoordTransition((-mainmenu.window.getWidth(), header.window.getHeight())))

    mmeh = MainMenuEventHandler(desktop)
    mainmenu.window.setEventHandler(mmeh)
    mmeh.onChange(mainmenu.window)
    desktop.setTransition("contents", CoordTransition((desktop.getWidth(), header.window.getHeight())))

    gui.setDesktop(desktop)

    while True:
        set_marquee()
        selected = gui.eventLoop(mainmenu.window)
        if selected != None: selected = mainmenu.window.getSelected().getData()[0]
        if hasattr(selected, "main"):
            mainmenu.window.keepShowingCursor()
            selected.main()
        elif hasattr(selected, "activate") and selected.activate():
            play_sound("click")
            gui.eventLoop(SelectedEventHandler(selected))

    pygame.quit()
    exit(0)
