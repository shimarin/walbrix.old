# -*- coding: utf-8 -*-
'''
@author: shimarin
'''

import os
import sys
import subprocess
import shutil
from optparse import OptionParser, OptionValueError

import system
import cli

usage = "[options] device_name vgname"

def setupOptions(parser):
    pass

def progress(x, y):
    print "%d/%d" % (x, y)
    sys.stdout.flush()

def run(options, args):
    if len(args) < 2: raise cli.Error("Insufficient parameters.")

    device_name = args[0]
    vgname = args[1]

    s = system.getSystem()
    progress(1, 7)
    s.createEFIPartitionTable(device_name)
    s.createPrimaryPartition(device_name, "1MiB", "-1")
    progress(2, 7)

    s.setLVMFlag(device_name, 1)
    progress(3, 7)
    s.reloadVolumeGroups()
    progress(4, 7)
    s.syncUdev()
    lvm_partition = s.getPartition(device_name, 1)
    #s.waitForDevice(lvm_partition)
    progress(5, 7)
    s.createPhysicalVolume(lvm_partition)
    progress(6, 7)
    s.createVolumeGroup(vgname, lvm_partition, "@wbvg", "@wbpv")
    progress(7, 7)
