# -*- coding:utf-8 -*-
import os
import sys
import pygame
import crypt
import threading
import subprocess
import urllib
import traceback

import wbui
import gui
import gui.list
import gui.messagebox
import gui.selectbox
import system
import vm
import status
import footer
import pygamehelper

import create
import operate
import resource_loader

domainList = None
window = None



# string resources
gui.res.register("string_domain_new",resource_loader.l({"en":u"New Virtual Machine", "ja":u"新規作成"}))
gui.res.register("string_domain_use",resource_loader.l({"en":u"%dMB Use", "ja":u"%dMB使用"}))
gui.res.register("string_domain_stop",resource_loader.l({"en":u"Stopped", "ja":u"停止中"}))
gui.res.register("string_domain_auto",resource_loader.l({"en":u"Automatic", "ja":u"自動"}))
gui.res.register("string_domain_manual",resource_loader.l({"en":u"Manual", "ja":u"手動"}))
gui.res.register("string_domain_new_virtual_machine",resource_loader.l({"en":u"A new virtual machine is to download and to create", "ja":u"新しい仮想マシンをダウンロードし、作成します"}))




class StackPanel(gui.Window):
    def __init__(self, size):
        gui.Window.__init__(self, size)
        self.stack = []
        self.bgImage = None
        self.bgColor = None
    def setBgImage(self, bgImage):
        self.bgImage = bgImage
    def setBgColor(self, bgColor):
        self.bgColor = bgColor
    def push(self, window, position = None):
        if position == None: position = (0, 0)
        self.stack.append((window, position))
        self.addChild("contents", window, position)
    def pop(self):
        if len(self.stack) == 0: return None
        rst = self.stack.pop()[1]
        if len(self.stack) > 0:
            self.addChild("contents", self.stack[-1][0], self.stack[-1][1])
        else:
            self.removeChild("contents")
    def paint(self, surface):
        if self.bgColor != None:
            surface.fill(self.bgColor)
        if self.bgImage != None:
            surface.blit(self.bgImage, (0, 0))

class DomainList(gui.list.List):
    def __init__(self, size):
        gui.list.List.__init__(self, size)
        self.setEventHandler(self)
    def setDomainList(self, domainList):
        self.domainList = domainList
        self.clearItem()
        self.addItem(gui.list.TextListItem(gui.res.string_domain_new, gui.res.font_domain_list))
        for domain in domainList:
            self.addItem(DomainListItem(domain))
    def getDomainList(self):
        return self.domainList
    def domainExists(self, name):
        if self.domainList == None: return
        return name in map(lambda x:x["name"], self.domainList)
    def onChange(self, target):
        set_marquee()
        
class DomainListItem(gui.list.ListItem):
    def __init__(self, domain):
        font = gui.res.font_domain_list
        self.hdr_img = font.render(domain["name"], True, gui.res.color_text)
        self.value_img = font.render((gui.res.string_domain_use % (domain["memory"]) if domain["memory"] != None else gui.res.string_domain_stop) + ':' + (gui.res.string_domain_auto if domain["autostart"] else gui.res.string_domain_manual), True, (96, 255, 96) if domain["memory"] != None else (255,96,96))
        gui.list.ListItem.__init__(self, max(self.hdr_img.get_height(), self.value_img.get_height()))
        self.domain = domain
    def getDomain(self):
        return self.domain
    def paint(self, surface, y):
        surface.blit(self.hdr_img, (0, y) )
        surface.blit(self.value_img, (surface.get_width() - self.value_img.get_width(), y))

def init():
    gui.res.register("font_domain_list", gui.res.font_system.getFont(20))

    global window
    window = StackPanel(gui.res.contents_panel.get_size())
    window.setBgImage(gui.res.contents_panel)

    global domainList
    domainList = DomainList(window.getSize())
    window.push(domainList)

def refresh():
    vmm = vm.getVirtualMachineManager()
    domains = vmm.getDomains()
    font = gui.res.font_system.getFont(20)

    domainList.setDomainList(domains)

def set_marquee():
    selected = domainList.getSelectedIndex()
    if selected == None: return
    if selected == 0:
        footer.window.setText(gui.res.string_domain_new_virtual_machine)
    else:
        domain = domainList.getSelected().getDomain()
        footer.window.setText(u"%s" % (domain["name"]))

def exists(name):
    if domainList == None: return False
    return domainList.domainExists(name)

def main():
    refresh()
    while True:
        set_marquee()
        if gui.eventLoop(domainList) == None: break
        if domainList.getSelectedIndex() == 0:
            if create.main(window): refresh()
        else:
            if operate.run(domainList.getSelected().getDomain()):
                refresh()

