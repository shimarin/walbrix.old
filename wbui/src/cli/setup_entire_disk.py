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

usage = "[options] device"

def setupOptions(parser):
    parser.add_option("-s", "--partiion-size", dest="partition_size", type="int", help="Size of system partition GB. entire disk is used if not specified.", default=None)
    parser.add_option("-f", "--filesystem", dest="filesystem", help="Filesystem type to use(Default=ext4)", default="ext4")

def run(options, args):
    if len(args) < 1: raise cli.Error("Insufficient parameters.")

    device = args[0]
    partition_size = options.partition_size
    filesystem = options.filesystem
    
    s = system.getSystem()

    if not s.isBlockSpecial(device): raise cli.Error("Invalid device is specified." % device)

    fs = s.getFilesystem(filesystem)

    s.deactivateVolumeGroups(False)
    s.createFdiskPartitionTable(device)

    if partition_size != None:
        lvmPartition = "%s2" % (device)
        s.createPrimaryPartition(device, "2048s", "%dGB" % (partition_size))
        s.createPrimaryPartition(device, "%dGB" % (partition_size), "-1")
        s.setLVMFlag(device, 2)
        #if not s.waitForDevice(lvmPartition): raise Exception("作成したパーティションにアクセスできませんでした")
        s.reloadVolumeGroups()
        s.createPhysicalVolume(lvmPartition)
        vgname = s.getVolumeGroupNameCandidate("wbvg", 99)
        if vgname is not None:
            s.createVolumeGroup(vgname, lvmPartition, "@wbvg", "@wbpv")
    else:
        s.createPrimaryPartition(device, "2048s", "-1")

    s.toggleBootFlag(device, 1)

    rootPartition = "%s1" % (device)
    s.waitForDevice(rootPartition)
    fs.mkfs(rootPartition)

    print rootPartition
