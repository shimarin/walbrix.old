# -*- coding: utf-8 -*-

import os,sys,traceback,random

import pygame

import system
import gui,gui.messagebox
import resource_loader
import dialogbox

import installer

window = None

# string resources

gui.res.register("string_installer_tools_rescue_mode",resource_loader.l({"en":u"%d-bit kernel to use to start the rescue mode. Are you sure?", "ja":u"%dビットカーネルを使用してレスキューモードを起動します。よろしいですか？"}))
gui.res.register("string_installer_tools_failed",resource_loader.l({"en":u"Failed to start the rescue mode (%s)", "ja":u"レスキューモードの起動に失敗しました(%s)"}))

gui.res.register("string_installer_tools_gui_benchmark",resource_loader.l({"en":u"The GUI benchmark takes about 10 seconds. Do you want to start?", "ja":u"GUIベンチマークには10秒ほどかかります。開始しますか？"}))
gui.res.register("string_installer_tools_off_screen_measure",resource_loader.l({"en":u"While measuring the speed of drawing off-screen ...", "ja":u"オフスクリーン描画の速度を計測中..."}))

gui.res.register("string_installer_tools_framebuffer",resource_loader.l({"en":u"While measuring the transfer rate of the frame buffer...", "ja":u"フレームバッファの転送速度を計測中..."}))
gui.res.register("string_installer_tools_speed",resource_loader.l({"en":u"Off-screen drawing speed indicates the speed of the memory and CPU, the frame buffer transfer rate indicates the speed of the bus.", "ja":u"オフスクリーン描画速度はCPUとメモリの速度を示し、フレームバッファの転送速度はバスの速度を示します。"}))

gui.res.register("string_installer_tools_result",resource_loader.l({"en":u"The benchmark results, off-screen drawing %.1fFPS, frame buffer transfer %.1fFPS.", "ja":u"ベンチマーク結果は、オフスクリーン描画 %.1fFPS, フレームバッファ転送 %.1fFPS です。"}))

gui.res.register("string_installer_tools_memory_test",resource_loader.l({"en":u"Start the memory testing tools memtest86+ to test the memory. Are you sure?", "ja":u"メモリ検査ツール memtest86+ を起動します。よろしいですか？"}))

gui.res.register("string_installer_tools_tool_failed",resource_loader.l({"en":u"Failed to start the memtest86+ (%s)", "ja":u"memtest86+の起動に失敗しました(%s)"}))
string_installer_tools_exit = resource_loader.l({"en":u"Exit to the Linux console. Are you sure?", "ja":u"Linuxコンソールに抜けます。よろしいですか？"})

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

def rescue(source_device, arch):
    if gui.messagebox.execute(gui.res.string_installer_tools_rescue_mode % (arch), ["ok", "cancel"]) != "ok": return False

    try:
        s= system.getSystem()
        with s.temporaryMount(source_device, None, "ro") as sourceDir:
            kernel = "%s/boot/vmlinuz.%d" % (sourceDir, arch)
            kernel_args = "video=uvesafb:mtrr:3,ywrap,1024x768-32 logo.nologo"
            initrd = "%s/boot/rescue.img" % (sourceDir)
            kexec_load_kernel(kernel, kernel_args, initrd)
        pygame.quit()
        os.execv("/usr/sbin/kexec", ("/usr/sbin/kexec", "-e"))
    except Exception, e:
        traceback.print_exc(file=sys.stderr)
        gui.messagebox.execute(gui.res.string_installer_tools_failed % (e), ["ok"], gui.res.color_dialog_negative)
        return False

    return True

def set_benchmark_progressbar(desktop, text):
    progressbar = gui.progressbar.ProgressBar(text)
    desktop.addChild("progressbar", progressbar, ((desktop.getWidth() - progressbar.getWidth()) / 2, (desktop.getHeight() - progressbar.getHeight()) / 2), -1)
    gui.yieldFrame()

def benchmark_gui():
    if gui.messagebox.execute(gui.res.string_installer_tools_gui_benchmark, ["ok", "cancel"]) != "ok": return False

    desktop = gui.getDesktop()
    installer.marquee.setText(None)

    set_benchmark_progressbar(desktop, gui.res.string_installer_tools_off_screen_measure)

    start_time = pygame.time.get_ticks()
    offscreen_cnt = 0
    while pygame.time.get_ticks() - start_time <= 5000:
        desktop.draw(gui.getScreen())
        offscreen_cnt += 1 

    set_benchmark_progressbar(desktop, gui.res.string_installer_tools_framebuffer)

    screen = gui.getScreen()
    start_time = pygame.time.get_ticks()
    framebuffer_cnt = 0
    while pygame.time.get_ticks() - start_time <= 5000:
        screen.set_at((random.randint(0, screen.get_width() - 1),random.randint(0, screen.get_height() - 1)), (random.randint(0,255),random.randint(0,255),random.randint(0,255)))
        pygame.display.update()
        framebuffer_cnt += 1

    desktop.removeChild("progressbar")

    installer.marquee.setText(gui.res.string_installer_tools_speed)

    gui.messagebox.execute(gui.res.string_installer_tools_result % (float(offscreen_cnt) / 5, float(framebuffer_cnt) / 5), ["ok"])

    return True

def console():
    if dialogbox.messagebox.execute(string_installer_tools_exit, dialogbox.DialogBox.OKCANCEL()) != "ok": return False

    pygame.quit()

    os.execv("/usr/bin/openvt", ["openvt", "-wsl", "--", "/usr/bin/fbterm", "--", "/usr/sbin/wb", "console-with-message"])
    return True
