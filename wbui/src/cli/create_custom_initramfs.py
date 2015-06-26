# -*- coding: utf-8 -*-
'''
@author: shimarin
'''

import os,subprocess

import cli
import system

usage = "EFI_system_partition"

files = [
    "etc/openvpn/client.crt",
    "etc/openvpn/client.key",
    "etc/runlevels/default/openvpn",
    "etc/conf.d/hostname",
    "etc/conf.d/net",
    "root/.ssh/authorized_keys"
]

def setupOptions(parser):
    pass

def run(options, args):
    if len(args) < 1: raise cli.Error("Insufficient parameters.")

    esp = args[0]

    s = system.getSystem()
    with s.temporaryMount(esp) as esp_dir:
        if not os.path.isdir("%s/EFI/Walbrix" % esp_dir):
            raise cli.Error("Partition %s doesn't contain an EFI directory for Walbrix" % esp)
        cpio = subprocess.Popen("cd / && cpio -o -H newc | xz -c --check=crc32 > %s/EFI/Walbrix/custom" % esp_dir, shell=True, stdin=subprocess.PIPE)
        for file in files:
            cpio.stdin.write("%s\n" % file)
        cpio.stdin.close()
        cpio.wait()
    
