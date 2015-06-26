# -*- coding: utf-8 -*-
'''
@author: shimarin
'''

import os,glob,subprocess
import cli,system

usage = "src dest"

def setupOptions(parser):
    parser.add_option("-s", "--snapshot-size", dest="snapshot_size", type="int", help="Size of boot snapshot size in GiB.", default=1)
    parser.add_option("--delete", dest="delete", action="store_true", help="Delete files from destination if deleted from source", default=False)
    parser.add_option("-v", "--verbose", dest="verbose", action="store_true", help="Verbose operation", default=False)

def src_lv(src, dest, options):
    s = system.getSystem()
    with s.openSnapshot(src, options.snapshot_size) as snapshot:
        return src_block(snapshot, dest, options)

def src_block(src, dest, options):
    s = system.getSystem()
    with s.temporaryMount(src, None, "ro") as tmpdir:
        return src_dir(tmpdir, dest, options)

def src_dir(src, dest, options):
    cmdline = ["rsync", "-ax"]
    if options.verbose: cmdline.append("-v")
    if options.delete: cmdline.append("--delete")
    cmdline.append(src if src.endswith('/') else src + '/')
    cmdline.append(dest)
    rsync = subprocess.Popen(cmdline)
    while True:
        try:
            rst = rsync.wait()
            if rst != 0: raise cli.Error("Rsync retuened error code:%d" % rst)
            return True
        except KeyboardInterrupt:
            pass # just to make sure subprocess is finished

def run(options, args):
    if len(args) < 2: raise cli.Error("Insufficient parameters.")

    src = args[0]
    dest = args[1]

    s = system.getSystem()

    if s.isBlockSpecial(src):
        if s.isLogicalVolume(src):
            return src_lv(src, dest, options)
        #else
        return src_block(src, dest, options)
    elif os.path.isdir(src):
        return src_dir(src, dest, options)
    #else
    raise cli.Error("Invalid source specified(must be a directory or a mountable block device)")
