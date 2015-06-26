# -*- coding:utf-8 -*-

import pygame
import subprocess
import os

import system
import vm
import wbui
import gui
import resource_loader

kernel_version = None
kernel_arch = None
kernel_date = None
ipaddress = None
cpus = None
cpu_clock = None
support_hvm = None
canvas = None
freememory = None
maxmemory = None
vpn_ipaddress = None

window = None

gui.res.register("color_status_positive", pygame.Color(94,223,255))
gui.res.register("color_status_negative", pygame.Color(255,103,121))



# string resources
gui.res.register("string_serial_number", resource_loader.l({"en":u"Serial Number", "ja":u"シリアルナンバー"}))
gui.res.register("string_kernel_version",resource_loader.l({"en":u"Kernel Version","ja":u"カーネルバージョン"}))
gui.res.register("string_kernel_arch",resource_loader.l({"en":u"Architecture","ja":u"アーキテクチャ"}))
gui.res.register("string_wbui_version",resource_loader.l({"en":u"WBUI Version","ja":u"WBUIバージョン"}))
gui.res.register("string_status_ipaddress",resource_loader.l({"en":u"IP Address","ja":u"IPアドレス"}))
gui.res.register("string_status_fail",resource_loader.l({"en":u"Failure to obtain","ja":u"取得失敗"}))
gui.res.register("string_cpu_core",resource_loader.l({"en":u"Number of CPU cores","ja":u"CPUコア数"}))
gui.res.register("string_individual",resource_loader.l({"en":u"%sIndividual","ja":u"%s個"}))
gui.res.register("string_unknown",resource_loader.l({"en":u"Unknown","ja":u"不明"}))
gui.res.register("string_cpu_clock",resource_loader.l({"en":u"CPU Speed","ja":u"CPUクロック"}))
gui.res.register("string_instruction",resource_loader.l({"en":u"Intel VT/AMD-V ","ja":u"仮想化命令サポート"}))
gui.res.register("string_there",resource_loader.l({"en":u"Available","ja":u"あり"}))
gui.res.register("string_no",resource_loader.l({"en":u"Available/Not available","ja":u"なし"}))
gui.res.register("string_free_memory",resource_loader.l({"en":u"Free Memory","ja":u"空きメモリ"}))
gui.res.register("string_central_server",resource_loader.l({"en":u"Central Server","ja":u"中央サーバ"}))
gui.res.register("string_connected",resource_loader.l({"en":u"Connected","ja":u"接続されています"}))
gui.res.register("string_not_connected",resource_loader.l({"en":u"Not connected","ja":u"接続されていません"}))
gui.res.register("string_kernel_date",resource_loader.l({"en":u"%s-%d-%s","ja":u"%s年%d月%s日"}))



class Window(gui.Window):
    def __init__(self):
        gui.Window.__init__(self, (400, 409))
        self.refresh()

    def refresh(self):
        global freememory, maxmemory, vpn_ipaddress
        (freememory, maxmemory) = vm.getVirtualMachineManager().getFreeMemoryInMb()
        vpn_ipaddress = get_vpn_ip_address()

    def onAddedAsChild(self, parent):
        self.refresh()

    def paint(self, surface):
        panel_topleft = ((surface.get_width() - gui.res.status_panel.get_width()) / 2, (surface.get_height() - gui.res.status_panel.get_height()) / 2)
        surface.blit(gui.res.status_panel, panel_topleft)

        self.item_offset = (panel_topleft[0] + 20, panel_topleft[1] + 24)

        self.draw_item(surface, 0, gui.res.string_serial_number, wbui.hostname)
        self.draw_item(surface, 1, gui.res.string_kernel_version, kernel_version)
        self.draw_item(surface, 2, gui.res.string_kernel_arch, kernel_arch)
        #self.draw_item(surface, 2, u"カーネル日付", self.kernel_date)
        self.draw_item(surface, 3, gui.res.string_wbui_version, wbui.version)
        connected = ipaddress != None
        self.draw_item(surface, 4, gui.res.string_status_ipaddress, ipaddress if connected else gui.res.string_status_fail, gui.res.color_status_positive if connected else gui.res.color_status_negative)

        self.draw_item(surface, 5, gui.res.string_cpu_core, (gui.res.string_individual % cpus) if cpus != None else gui.res.string_unknown, gui.res.color_status_positive if cpus != None else gui.res.color_status_negative)

        self.draw_item(surface, 6, gui.res.string_cpu_clock, ("%dMHz" % (cpu_clock)) if cpu_clock != None else gui.res.string_unknown, gui.res.color_status_positive if cpu_clock != None else gui.res.color_status_negative)

        self.draw_item(surface, 7, gui.res.string_instruction, gui.res.string_there if support_hvm == True else gui.res.string_no if support_hvm == False else gui.res.string_unknown, gui.res.color_status_positive if support_hvm != None else gui.res.color_status_negative)
        if freememory != None and maxmemory != None:
            self.draw_item(surface, 8, gui.res.string_free_memory, "%d/%dMB" % (freememory, maxmemory))
        else:
            self.draw_item(surface, 8, gui.res.string_free_memory, "-", gui.res.color_status_negative)
            
        connected = vpn_ipaddress != None
        self.draw_item(surface, 9, gui.res.string_central_server, gui.res.string_connected if connected else gui.res.string_not_connected, gui.res.color_status_positive if connected else gui.res.color_status_negative)

    def draw_item(self, surface, num, header, value, color=None):
        if color == None: color = gui.res.color_status_positive
        hdr_img = gui.res.font_status_text.render(header, True, gui.res.color_text)
        value_img = gui.res.font_status_text.render(value, True, color)
        y = num * 32 + self.item_offset[1]
        surface.blit(hdr_img, (self.item_offset[0], y) )
        surface.blit(value_img, (surface.get_width() - value_img.get_width() - self.item_offset[0], y))
    
def get_vpn_ip_address():
    try:
        return system.get_ip_address("tun0")
    except:
        pass
    return None

def init():
    s = system.getSystem()
    uname = os.uname()

    global kernel_version, kernel_arch, kernel_date, ipaddress, cpus, cpu_clock, support_hvm, canvas, vpn_ipaddress
    kernel_version = uname[2]
    kernel_arch = s.getArchitectureString()
    kernel_date_str = uname[3].replace('Darwin Kernel ', '').split()
    kernel_date = gui.res.string_kernel_date % (kernel_date_str[7],{"Jan":1,"Feb":2,"Mar":3,"Apr":4,"May":5,"Jun":6,"Jul":7,"Aug":8,"Sep":9,"Oct":10,"Nov":11,"Dec":12}[kernel_date_str[3]],kernel_date_str[4])

    try:
        ipaddress = system.get_ip_address_which_reaches_default_gateway()
    except:
        pass # keep it None
    
    # CPU情報を得る
    cpuinfo = subprocess.Popen("lscpu", shell=True, stdout=subprocess.PIPE, close_fds=True)
    line = cpuinfo.stdout.readline()
    while line:
        if line.startswith("CPU(s):"):
            cpus = int(line[10:].strip())
        elif line.startswith("CPU MHz:"):
            cpu_clock = int(float(line[10:].strip()))
        line = cpuinfo.stdout.readline()
    cpuinfo.wait()

    support_hvm = os.system("xl info|egrep '^xen_caps.*hvm-' -q") == 0

    canvas = pygame.Surface((400, 400), pygame.SRCALPHA, 32)
    vpn_ipaddress = None

    gui.res.register("status_panel", resource_loader.loadImage("status_panel.png"))
    gui.res.register("font_status_text", gui.res.font_system.getFont(18))

    global window
    window = Window()

def get_serial_number():
    return wbui.hostname # 今は

def get_ip_address():
    return ipaddress

def refresh():
    if window != None: window.refresh()

def draw_item(num, header, value, color=(96,255,96)):
    hdr_img = wbui.smallfont.render(header, True, (255, 255, 255))
    value_img = wbui.smallfont.render(value, True, color)
    y = num * wbui.smallfont.get_height()
    canvas.blit(hdr_img, (0, y) )
    canvas.blit(value_img, (canvas.get_rect().w - value_img.get_rect().w, y))

def get_canvas():
    return canvas

def is_connected():
    return vpn_ipaddress != None

def is_active():
    return False

def main():
    window.refresh()

