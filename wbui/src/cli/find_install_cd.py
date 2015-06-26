# -*- coding: utf-8 -*-
'''
@author: shimarin
'''

import os
import sys
import time
from optparse import OptionParser, OptionValueError

import system
import cli
import subprocess

usage = "[options]"

def setupOptions(parser):
    pass

def check_output(cmd):
    return subprocess.check_output(cmd, shell=True)

def check_if_appropriate_source(srcdir):
    s = system.getSystem()
    if not os.path.exists("%s/wb-%s.tar.xz" % (srcdir, s.getArchitectureString())): return False
    if not os.path.isdir("%s/EFI/Walbrix" % srcdir): return False
    return True

def run(options, args):
    s = system.getSystem()

    devices = check_output("lsblk -nr -o KNAME,FSTYPE,LABEL")
    for line in devices.split('\n'):
        if line == "": continue;
        device = line.split(' ')
        if len(device) < 2: raise Exception(line)
        if device[1] not in ("iso9660","vfat"): continue
        device_name = "/dev/%s" % device[0]
        try:
            with s.temporaryMount(device_name, None, "ro") as tmp:
                if check_if_appropriate_source(tmp):
                    print "%s\t%s" % (device_name, device[2])
        except:
            pass
