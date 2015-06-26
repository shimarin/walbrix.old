# -*- coding: utf-8 -*-
'''
@author: shimarin
'''

import os,glob,subprocess
import cli,system

usage = "src_device [dest_file_or_device]"

def setupOptions(parser):
    parser.add_option("-s", "--snapshot-size", dest="snapshot_size", type="int", help="Size of boot snapshot size in GiB.", default=1)
    #parser.add_option("-v", "--verbose", dest="verbose", action="store_true", help="Verbose operation", default=False)

def src_lv(src, dest, options):
    s = system.getSystem()
    with s.openSnapshot(src, options.snapshot_size) as snapshot:
        return src_block(snapshot, dest, options)

def src_block(src, dest, options):
    s = system.getSystem()
    block_size = s.getPhysicalSectorSize(src)
    cmdline = ["dd", "if=%s" % src, "bs=%d" % block_size]
    if dest: cmdline.append("of=%s" % dest)
    rsync = subprocess.Popen(cmdline)
    while True:
        try:
            return rsync.wait() == 0
        except KeyboardInterrupt:
            pass # just to make sure subprocess is finished


def run(options, args):
    if len(args) < 1: raise cli.Error("Insufficient parameters.")

    src = args[0]
    dest = None if len(args) < 2 else args[1]

    s = system.getSystem()

    if not s.isBlockSpecial(src):
        raise cli.Error("Source must be a block device")

    if s.isLogicalVolume(src):
        return src_lv(src, dest, options)
    #else
    return src_block(src, dest, options)
