# -*- coding:utf-8 -*-

import os
import stat

import d3des
from struct import pack, unpack

def check_pathelement_security(file):
    if file.find("../") >= 0: raise Exception("Security exception: Output file contains a fishy path element.")

def apply_configuration(item, value, root_path):
    type = item.get("type")
    if type == "vncpasswd":
        apply_vncpasswd_configuration(item, value, root_path)
    else:
        pass

def apply_vncpasswd_configuration(item, value, root_path):
    file = item.get("file")
    if not file: return
    check_pathelement_security(file)

    ek = d3des.deskey(pack('8B', *d3des.vnckey), False)
    encrypted = d3des.desfunc((value+'\x00'*8)[:8], ek)

    target_file = "%s/%s" % (root_path, file)
    with open(target_file, "w") as vncpasswd:
        vncpasswd.write(encrypted)

    os.chmod(target_file, stat.S_IRUSR | stat.S_IWUSR)

def get_label_from_config_item(item):
    labels = item.findall("label")
    if labels and len(labels) > 0:
        return labels[0].text
    return item.get("name")

class VAConfiguration:
    def __init__(self, metadata):
        self.items = {}
        if metadata != None:
            items = metadata.findall("./config-item")
            if items:
                for item in items:
                    name = item.get("name")
                    if name:
                        self.items[name] = item

        self.values = {}

    def get_config_items(self):
        return self.items

    def set_config_item_value(self, name, value):
        self.values[name] = value

    def apply_configuration(self, root_path):
        for item_name in self.items:
            if item_name in self.values:
                apply_configuration(self.items[item_name], self.values[item_name], root_path)
