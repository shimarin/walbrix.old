# -*- coding:utf-8 -*-
import os
import urllib2
import __builtin__
from xml.etree import ElementTree

import system

ext_catalogs = []

# /etc/wbuiから設定の読み込み
def load():
    if os.path.isfile("/etc/wbui/catalogs"):
	with open("/etc/wbui/catalogs") as f:
            line = f.readline()
            while line:
                url = line.strip()
                if url != "" and not url.startswith("#"):
                    ext_catalogs.append(url)
                line = f.readline()

def getURL():
    if system.region() != "jp":
        return "http://va.walbrix.net/index-%s.xml" % system.region()
    #else
    return "http://va.walbrix.net/index.xml"

def open(file = None):
    if file == None: file = getURL()
    if file.startswith("http://") or file.startswith("https://"):
        return urllib2.urlopen(file)
    else: return __builtin__.open(file)

def parse(xml_stream):
    arch = system.getSystem().getArchitectureString()
    doc = ElementTree.parse(xml_stream)
    items = []
    for item in doc.findall(".//item"):
        i = {}
        i["id"] = item.get("id")
        i["minimum_ram"] = item.get("minimum_ram")
        i["minimum_hd"] = item.get("minimum_hd")
        i["title"] = item.findtext("title")
        i["description"] = item.findtext("description")
        i["image"] = item.find("image")
        if i["image"] != None: i["image"] = i["image"].get("uri")
        i["tarball"] = item.get("tarball")
        i["arch"] = item.get("arch")
        if i["arch"] == None: i["arch"] = "i686"
        if arch == i["arch"] or (arch == "x86_64" and i["arch"] == "i686"):
            items.append(i)
    return items
