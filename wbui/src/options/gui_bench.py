# -*- coding:utf-8 -*-
import random
import pygame

import gui
import dialogbox
import footer
import resource_loader

# string resources

gui.res.register("string_benchmark_start_desc",resource_loader.l({"en":u"The GUI benchmark takes about 10 seconds.Do you want to start?", "ja":u"GUIベンチマークには10秒ほどかかります。開始しますか？"}))

gui.res.register("string_drawing_measure",resource_loader.l({"en":u"While measuring the speed of drawing off-screen ...", "ja":u"オフスクリーン描画の速度を計測中..."}))

gui.res.register("string_frame_buffer_measure",resource_loader.l({"en":u"While measuring the transfer rate of the frame buffer ...", "ja":u"フレームバッファの転送速度を計測中..."}))

gui.res.register("string_speed_indication",resource_loader.l({"en":u"Off-screen drawing speed indicates the speed of the memory and CPU, the frame buffer transfer rate indicates the speed of the bus.", "ja":u"オフスクリーン描画速度はCPUとメモリの速度を示し、フレームバッファの転送速度はバスの速度を示します。"}))

gui.res.register("string_benchmark_result",resource_loader.l({"en":u"Benchmark results, off-screen drawing %.1fFPS, frame buffer transfer %.1fFPS.", "ja":u"ベンチマーク結果は、オフスクリーン描画 %.1fFPS, フレームバッファ転送 %.1fFPS です。"}))

def set_benchmark_progressbar(desktop, text):
    message = dialogbox.DialogBox.MESSAGE(text)
    progressbar = dialogbox.DialogBox(message)
    desktop.addChild("progressbar", progressbar, ((desktop.getWidth() - progressbar.getWidth()) / 2, (desktop.getHeight() - progressbar.getHeight()) / 2), -1)
    gui.yieldFrame()

def benchmark_gui():
    if dialogbox.messagebox.execute(gui.res.string_benchmark_start_desc, dialogbox.DialogBox.OKCANCEL()) != "ok": return False

    desktop = gui.getDesktop()
    footer.window.setText(None)

    set_benchmark_progressbar(desktop, gui.res.string_drawing_measure)

    start_time = pygame.time.get_ticks()
    offscreen_cnt = 0
    while pygame.time.get_ticks() - start_time <= 5000:
        desktop.draw(gui.getScreen())
        offscreen_cnt += 1 

    set_benchmark_progressbar(desktop, gui.res.string_frame_buffer_measure)

    screen = gui.getScreen()
    start_time = pygame.time.get_ticks()
    framebuffer_cnt = 0
    while pygame.time.get_ticks() - start_time <= 5000:
        screen.set_at((random.randint(0, screen.get_width() - 1),random.randint(0, screen.get_height() - 1)), (random.randint(0,255),random.randint(0,255),random.randint(0,255)))
        pygame.display.update()
        framebuffer_cnt += 1

    desktop.removeChild("progressbar")

    footer.window.setText(gui.res.string_speed_indication)

    dialogbox.messagebox.execute(gui.res.string_benchmark_result % (float(offscreen_cnt) / 5, float(framebuffer_cnt) / 5))

    return False

