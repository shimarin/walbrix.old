# -*- coding: utf-8 -*-
from __future__ import print_function
import time
import os
import re
import sys
import signal
import threading
import subprocess
import select
import traceback
import io
import base64
import shutil

import pygame
import gui
import gui.res
import gui.list
import gui.selectbox
import gui.progressbar
import system
import theme
import install
import upgrade
import tools
import dialogbox.messagebox
import resource_loader

wb_version = None

cpu_supports_64bit = None
efi = None
source_devices = []
existing_systems = []

bitwidth_to_arch = { 32: "i686", 64: "x86_64" }

header = None
marquee = None

no_check_source = False

fb_bit_depth = None

# string resources

gui.res.register("string_inst_hd_check",resource_loader.l({"en":u"Checking the installation disk ...", "ja":u"インストールディスクを確認中..."}))
gui.res.register("string_inst_exists_sys",resource_loader.l({"en":u"Checking for existing systems ...", "ja":u"既存のシステムを確認中..."}))
gui.res.register("string_inst_walbrix_install",resource_loader.l({"en":u"Walbrix %s installer", "ja":u"Walbrix %s インストーラ"}))
gui.res.register("string_inst_exit_off",resource_loader.l({"en":u"Exit the installer and power off the system.", "ja":u"インストーラを終了し、システムの電源を切ります。"}))
gui.res.register("string_inst_installation_desc",resource_loader.l({"en":u"You through the installation of Walbrix. Please select the version that you want to install and press the Enter key. Hard disk where you installed will be erased.", "ja":u"Walbrixのインストールを行います。Enterキーを押してインストールするバージョンを選択してください。インストール先のハードディスクは全て消去されます。"}))

gui.res.register("string_inst_detected_desc",resource_loader.l({"en":u"Walbrix installed has been already detected by the installer. You can upgrade it.", "ja":u"既にインストール済みの Walbrixがインストーラによって検出されています。これをアップグレードすることができます。"}))

gui.res.register("string_inst_tools_",resource_loader.l({"en":u"You can use the various tools as well start the rescue mode.", "ja":u"レスキューモードの起動ほか各種ツールを利用できます。"}))

gui.res.register("string_inst_start_",resource_loader.l({"en":u"Preparation for the start ...", "ja":u"起動の準備中..."}))

gui.res.register("string_inst_failed_detect",resource_loader.l({"en":u"Failed to detect the type of CPU. Treated as non-compliant 64bit (%s)", "ja":u"CPU種別の検出に失敗しました。64bit非対応として扱います (%s)"}))

gui.res.register("string_inst_verify_again_hd",resource_loader.l({"en":u"We were unable to verify your installation disk. Do you want to try to discover it again?", "ja":u"インストールディスクを確認できませんでした。再度検出を試みますか？"}))
gui.res.register("string_inst_inatall",resource_loader.l({"en":u"Install", "ja":u"インストール"}))
gui.res.register("string_inst_upgrade",resource_loader.l({"en":u"Upgrade", "ja":u"アップグレード"}))

gui.res.register("string_inst_tool",resource_loader.l({"en":u"Tool", "ja":u"ツール"}))

gui.res.register("string_inst_end_",resource_loader.l({"en":u"End", "ja":u"終了"}))

gui.res.register("string_inst_64_bit",resource_loader.l({"en":u"64-bit Walbrix %s (recommended)", "ja":u"64ビット Walbrix %s(推奨)"}))

gui.res.register("string_install_64_version_desc",resource_loader.l({"en":u"Install the 64-bit version of Walbrix. Please install here is usually because this computer supports the 64-bit.", "ja":u"64ビット版の Walbrixをインストールします。このコンピュータは 64ビットに対応していますので通常はこちらをインストールしてください。"}))

gui.res.register("string_64_rescue_mode",resource_loader.l({"en":u"64-bit rescue mode", "ja":u"64ビット レスキューモード"}))

gui.res.register("string_64_start_kernel",resource_loader.l({"en":u"start the rescue mode using the 64-bit version of the kernel.", "ja":u"64ビット版のカーネルを使用してレスキューモードを起動します。"}))

gui.res.register("string_inst_32_bit",resource_loader.l({"en":u"32-bit Walbrix %s", "ja":u"32ビット Walbrix %s"}))

gui.res.register("string_install_32_version_desc",resource_loader.l({"en":u"Install the 32-bit version of Walbrix. %s", "ja":u"32ビット版の Walbrixをインストールします。%s"}))
gui.res.register("string_not_supproted_64bit",resource_loader.l({"en":u"(This computer does not support 64-bit operation)", "ja":u"(このコンピュータは 64ビット動作に対応していません)"}))

gui.res.register("string_32bit_rescue_mode",resource_loader.l({"en":u"32-bit rescue mode", "ja":u"32ビット レスキューモード"}))

gui.res.register("string_32_start_kernel",resource_loader.l({"en":u" start the rescue mode using the kernel of 32-bit version.", "ja":u"32ビット版のカーネルを使用してレスキューモードを起動します。"}))
gui.res.register("string_walbrix_bit_desc",resource_loader.l({"en":u"%s:%d bit Walbrix %s", "ja":u"%s: %dビット Walbrix %s"}))
gui.res.register("string_inst_walbrix_intallation_desc",resource_loader.l({"en":u"%s is already installed in the %d %s Walbrix bit version using the installation disk upgrade.", "ja":u"%s に既にインストールされている、%dビット版 Walbrix %s をこのインストールディスクを使ってアップ(ダウン)グレードします。"}))

gui.res.register("string_inst_gui_benchmark",resource_loader.l({"en":u"GUI benchmark", "ja":u"GUIベンチマーク"}))

gui.res.register("string_inst_speed_desc",resource_loader.l({"en":u"Simple to measure the processing speed of this computer.", "ja":u"このコンピュータの処理速度を簡易計測します。"}))

gui.res.register("string_inst_console",resource_loader.l({"en":u"Console", "ja":u"コンソール"}))

gui.res.register("string_linux_console_exit",resource_loader.l({"en":u"Exit to the Linux console.", "ja":u"Linuxコンソールに抜けます。"}))
gui.res.register("string_inst_upgrade_",resource_loader.l({"en":u"Do you want to upgrade the installed system (device %s %s %dbit)?", "ja":u"デバイス %s にインストール済みのシステム(%s %dbit)をアップグレードしますか？"}))
gui.res.register("string_uuid_desc_",resource_loader.l({"en":u"Installation of the partition identifier (UUID) could not be retrieved", "ja":u"インストール先パーティションの識別子(UUID)を取得できませんでした"}))

def determineSVGAVideoMode(acceptable_modes):
    mode = int(subprocess.check_output("vbetool vbemode get", shell=True, close_fds=True)) - 16384 + 0x200
    if mode in acceptable_modes: return "0x%x" % mode
    #else
    return None

def copyWBUI(source_dir, target_dir):
    system.getSystem().execShell("cd %s && unxz -c %s/EFI/Walbrix/wbui | cpio -idmu --quiet" % (target_dir, source_dir), True)

def copyRescueImage(source_dir, bitwidth, target_dir, kernel=False):
    if kernel:
        shutil.copy("%s/isolinux/vmlinuz.%d" % (source_dir, bitwidth), "%s/boot/kernel" % target_dir)
        shutil.copy("%s/isolinux/rescue%d.img" % (source_dir, bitwidth), "%s/boot/rescue" % target_dir)
    else:
        shutil.copy("%s/isolinux/rescue%d.img" % (source_dir, bitwidth), "%s/boot/rescue.img" % target_dir)
        symlink_for_compat = "%s/boot/rescue" % target_dir
        if os.path.islink(symlink_for_compat): os.unlink(symlink_for_compat)
        if not os.path.exists(symlink_for_compat): os.symlink("rescue.img", symlink_for_compat)

    shutil.copy("%s/isolinux/wbui.img" % (source_dir), "%s/boot/wbui.img" % target_dir)

def copyBootImages(source_dir, target_dir):
    s = system.getSystem()
    s.execShell("cp -a %s/EFI/Walbrix/. %s/EFI/Walbrix/" % (source_dir, target_dir))

'''
to test:
python -c 'import installer;installer.fb_bit_depth=32;installer.fb_id="VESA";installer.createGrubMenu("/dev/sda1", "/tmp")'
'''
def createGrubMenu(root_partition, target_dir, arch, dom0_mem = "256M"):

    def xen_opts(dom0_mem=None, graphics=None):
        xen_opts = []
        if dom0_mem:
            xen_opts.append("dom0_mem=%s,max:%s" % (dom0_mem, dom0_mem))
        if graphics == "drm":
            pass
        elif graphics == "vesa":
            if fb_bit_depth:
                xen_opts.append("vga=gfx-640x480x%d" % fb_bit_depth)
            else:
                vbe_mode = determineSVGAVideoMode([0x310,0x311,0x312,0x331,0x33f])
                if vbe_mode == None: vbe_mode = "0x312"
                xen_opts.append("vga=mode-%s" % vbe_mode)

        return " ".join(xen_opts)

    def kernel_opts(graphics, modprobe_blacklist = None):
        kernel_opts = []

        if graphics == "drm":
            kernel_opts.append("video=640x480-32")
        elif graphics == "vesa":
            kernel_opts.append("nomodeset")
        if modprobe_blacklist:
            kernel_opts.append("modprobe.blacklist=%s" % modprobe_blacklist)
        return " ".join(kernel_opts)

    grubDir = "%s/boot/grub" % (target_dir)
    if not os.path.isdir(grubDir): os.makedirs(grubDir)
    
    grubCfg = "%s/grub.cfg" % (grubDir)
    grubVarsCfg = "%s/EFI/Walbrix/grubvars.cfg" % (target_dir)

    s = system.getSystem()
    partitionUuid = s.determinePartitionUuid(root_partition)
    if partitionUuid is None: raise Exception(gui.res.string_uuid_desc_)

    modprobe_blacklist = None
    if os.path.isfile("/proc/cmdline"):
        cmdline = open('/proc/cmdline').read()
        r = re.compile(r'modprobe\.blacklist=\S*')
        match = r.match(cmdline)
        if match:
            splitted = match.group().split('=')
            if len(splitted) > 1: modprobe_blacklist = splitted[1]

    splash = False
    # スプラッシュが有効かどうか
    if os.path.isdir("%s/etc/splash/wb" % target_dir):
        splash = True
    else:
        with s.temporaryMount(root_partition, None, "ro") as root_dir:
            splash = os.path.isdir("%s/etc/splash/wb" % root_dir)
    splash = "splash=silent,theme:wb console=tty1 quiet" if splash else ""

    graphics = "vesa" if fb_id and fb_id.startswith("VESA") else "drm"

    with open(grubCfg, "w") as grub_cfg:
        grub_cfg.write("source /EFI/Walbrix/grub.cfg\n")

    with open(grubVarsCfg, "w") as grub_vars_cfg:
        grub_vars_cfg.write("set arch=%d\n" % arch)
        grub_vars_cfg.write("set UUID=%s\n" % partitionUuid)
        grub_vars_cfg.write("set xen_args=\"%s\"\n" % xen_opts(dom0_mem, graphics))
        grub_vars_cfg.write("set splash=\"%s\"\n" % splash)
        grub_vars_cfg.write("set linux_args=\"%s\"\n" % kernel_opts(graphics,modprobe_blacklist))

    xenCfg = "%s/EFI/Walbrix/xen.cfg" % (target_dir)
    with open(xenCfg, "w") as xen_cfg:
        xen_cfg.write("[global]\n")
        xen_cfg.write("default=Walbrix\n\n")
        xen_cfg.write("[Walbrix]\n")
        xen_cfg.write("options=%s\n" % xen_opts(dom0_mem, graphics))
        xen_cfg.write("kernel=kernel.64 dolvm domdadm scandelay edd=off root=UUID=%s %s %s init_opts=4\n" % (partitionUuid, kernel_opts(graphics,modprobe_blacklist), splash))
        xen_cfg.write("ramdisk=initramfs.64\n\n")
        xen_cfg.write("[noui]\n")
        xen_cfg.write("options=%s\n" % xen_opts(dom0_mem, graphics))
        xen_cfg.write("kernel=kernel.64 dolvm domdadm scandelay edd=off root=UUID=%s %s\n" % (partitionUuid, kernel_opts(graphics,modprobe_blacklist)))
        xen_cfg.write("ramdisk=initramfs.64\n")

    # create an empty cpio.xz file (override it to customize rescue env)
    s.execShell("echo -n '' |cpio -o --quiet -H newc|xz -c --check=crc32 > %s/EFI/Walbrix/custom" % target_dir)

def determineInstallDisk():
    s = system.getSystem()
    with dialogbox.messagebox.open(gui.res.string_inst_hd_check) as progressBar:
        with s.openWbForInput("find_install_cd") as find_install_cd:
            nbr = s.getNonblockingReader(find_install_cd.stdout)
            line = nbr.readline()
            while line != "":
                if line != None:
                    source_devices.append(line.rstrip("\n").split('\t'))
                gui.yieldFrame()
                line = nbr.readline()

def findExistingSystems():
    s = system.getSystem()
    with dialogbox.messagebox.open(gui.res.string_inst_exists_sys) as progressBar:
        try:
            with s.openWbForInput("find_existing_systems") as find_existing_systems:
                nbr = s.getNonblockingReader(find_existing_systems.stdout)
                line = nbr.readline()
                while line != "":
                    # esp-rootfs-kernel-arch
                    if line != None:
                        existing_systems.append(line.rstrip("\n").split('\t'))
                    gui.yieldFrame()
                    line = nbr.readline()
        except:
            traceback.print_exc(file=sys.stderr)
            return False
    return True

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

class Upgrade(gui.list.List, Contents, gui.list.ListEventHandler):
    def __init__(self):
        gui.list.List.__init__(self, (gui.res.contents_panel.get_size()))
        Contents.__init__(self, gui.res.string_inst_detected_desc)
        self.setBgImage(gui.res.contents_panel)
        self.setEventHandler(self)
    def setMarquee(self):
        marquee.setText(self.getSelected().getData()[5])
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

def kexec_cmdline(kernel, kernel_args = None, initrd = None):
    cmdline = ["/usr/sbin/kexec", "-l", kernel]
    if kernel_args != None: cmdline.append("--append=%s" % kernel_args)
    if initrd != None: cmdline.append("--initrd=%s" % initrd)
    return cmdline

def kexec_load_kernel(kernel, kernel_args = None, initrd = None):
    s = system.getSystem()
    cmdline = kexec_cmdline(kernel, kernel_args, initrd)
    with dialogbox.messagebox.open(gui.res.string_inst_start_) as pb:
        with s.openCancellableProcessForInput(cmdline) as kexec:
            nbr = s.getNonblockingReader(kexec.stdout)
            line = nbr.readline()
            while line != "":
                gui.yieldFrame()
                line = nbr.readline()

def check():
    global wb_version
    wb_version = os.uname()[2].replace("-gentoo", "")

    global cpu_supports_64bit, efi
    s = system.getSystem()
    cpu_supports_64bit = s.doesCPUSupport64BitMode()
    if cpu_supports_64bit == None:
        dialogbox.messagebox.execute(gui.res.string_inst_failed_detect % (e), None, gui.res.caution_sign)
        cpu_supports_64bit = False
    efi = os.path.isdir("/sys/firmware/efi")

    if not no_check_source and len(source_devices) == 0:
        determineInstallDisk()
        while len(source_devices) == 0:
            if dialogbox.messagebox.execute(gui.res.string_inst_verify_again_hd, dialogbox.DialogBox.OKCANCEL(), gui.res.caution_sign) != "ok": break
            determineInstallDisk()

    findExistingSystems()
    return True

def start():
    desktop = gui.DesktopWindow(gui.getScreen().get_size(), gui.res.background)
    gui.setDesktop(desktop)

    if not check(): return False

    global header, marquee
    header = Header()
    marquee = Marquee()

    mainmenu = MainMenu()
    mme = MainMenuEventHandler()
    mainmenu.setEventHandler(mme)
    install.window = Install()
    upgrade.window = Upgrade()
    tools.window = Tools()

    mainmenu_items = []
    source_available = len(source_devices) > 0

    if source_available:
        mainmenu_items.append(MainMenu.ListItem(gui.res.icon_install, gui.res.string_inst_inatall, install.window))
    if source_available and len(existing_systems) > 0:
        mainmenu_items.append(MainMenu.ListItem(gui.res.icon_upgrade, gui.res.string_inst_upgrade, upgrade.window))
    mainmenu_items.append(MainMenu.ListItem(gui.res.icon_tools, gui.res.string_inst_tool, tools.window))

    mainmenu.addItems(mainmenu_items)
    items_height = sum(map(lambda x:x.getHeight(), mainmenu_items))

    mainmenu.addItem(gui.list.Separator(332 - mainmenu.getMarginTop() - items_height))
    mainmenu.addItem(MainMenu.SmallListItem(gui.res.icon_shutdown, gui.res.string_inst_end_))

    if cpu_supports_64bit:
        install.window.addItem(gui.list.TextListItem(gui.res.string_inst_64_bit % wb_version, gui.res.font_select_option, None, None, ("install", 64, gui.res.string_install_64_version_desc)))
        if source_available: tools.window.addItem(gui.list.TextListItem(gui.res.string_64_rescue_mode, gui.res.font_select_option, None, None, ("rescue", gui.res.string_64_start_kernel, 64)))
    install.window.addItem(gui.list.TextListItem(gui.res.string_inst_32_bit % wb_version, gui.res.font_select_option, None, None, ("install", 32, gui.res.string_install_32_version_desc % (u"" if cpu_supports_64bit else gui.res.string_not_supproted_64bit))))
    #install.window.addItem(gui.list.TextListItem(u"Walbrix 2.6.33(旧バージョン)", gui.res.font_select_option, None, None, ("install2633", 32, u"2010年版の Walbrixをインストールします。2003年前後までの古いコンピュータで最新版が動作しない場合はこれをお使い下さい。")))
    if source_available: tools.window.addItem(gui.list.TextListItem(gui.res.string_32bit_rescue_mode, gui.res.font_select_option, None, None, ("rescue", gui.res.string_32_start_kernel, 32)))

    for existing_system in existing_systems:
        device = existing_system[0].split('/')[-1]
        version = existing_system[2].replace("-gentoo", "")
        arch = int(existing_system[3])
        if cpu_supports_64bit or arch == 32:
            upgrade.window.addItem(gui.list.TextListItem(gui.res.string_walbrix_bit_desc % (device, arch, version), gui.res.font_select_option, None, None, ("upgrade", existing_system[0], existing_system[1], version, arch, gui.res.string_inst_walbrix_intallation_desc % (existing_system[0], arch, version))))

    # memtest, benchmark
    #tools.window.addItem(gui.list.TextListItem(u"メモリテスト(memtest86+)", gui.res.font_select_option, None, None, ("memtest", u"このコンピュータのメモリに不良がないかテストします。")))
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
                if install.run(source_devices[0][0], bitwidth_to_arch[action[1]]): return True
                else: continue
            if action[0] == "install2633":
                if install.run2633(source_devices[0][0]): return True
                else: continue
            elif action[0] == "upgrade":
                if dialogbox.messagebox.execute(gui.res.string_inst_upgrade_ % (action[1], action[3], action[4]), dialogbox.DialogBox.OKCANCEL()) != "ok": continue
                if upgrade.run(source_devices[0][0], action[1], action[2], bitwidth_to_arch[action[4]]): return True
            elif action[0] == "rescue":
                if not tools.rescue(source_devices[0][0], action[2]): continue
            elif action[0] == "memtest":
                if not tools.memtest(source_devices[0][0]): continue
            elif action[0] == "benchmark":
                if not tools.benchmark_gui(): continue
            elif action[0] == "console":
                if not tools.console(): continue

def main(options, args):
    for arg in args:
        source_devices.append([arg, None]) 

    s = system.getSystem()

    global fb_bit_depth, fb_id
    fb_bit_depth = s.determineFrameBufferBitDepth()
    fb_id = s.getFrameBufferIdString()

    pygame.display.init()
    pygame.font.init()
    pygame.mouse.set_visible(False)
    pygame.joystick.init()

    displayMode = pygame.HWSURFACE|pygame.DOUBLEBUF
    driver = pygame.display.get_driver()
    if driver == "directfb": displayMode = pygame.FULLSCREEN
    elif driver == "fbcon": displayMode |= pygame.FULLSCREEN

    screen = pygame.display.set_mode((640,480), displayMode)
    clock = pygame.time.Clock()

    joystick = pygame.joystick.Joystick(0) if pygame.joystick.get_count() > 0 else None
    gui.res.register("joystick", joystick)
    if joystick != None: joystick.init()

    gui.setScreen(screen)
    gui.setClock(clock)
    gui.setFrameRate(30)

    fontfile = None
    fontfile_candidates = [ theme.getThemeFilePath("pfont.ttf"), "/System/Library/Fonts/ヒラギノ角ゴ ProN W3.otf", "/usr/share/fonts/vlgothic/VL-PGothic-Regular.ttf"]
    for fc in fontfile_candidates:
        if fc != None and os.path.exists(fc):
            fontfile = fc
            break
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

    if options != None:
        global no_check_source
        no_check_source = options.no_check_source

    try:
        start()
    finally:
        pygame.quit()
        os.system("init 3")

if __name__ == '__main__':
    main(None,None)
