# -*- coding: utf-8 -*-

import os,sys,shutil
import cli

usage = "srcdir destdir"

def setupOptions(parser):
    pass

def run(options, args):
    if len(args) < 2: raise cli.Error("Insufficient parameters.")

    src = args[0]
    dst = args[1]
    if not os.path.isdir(src):
        raise cli.Error("Invalid source directory '%s'" % src)
    if not os.path.isdir(dst):
        raise cli.Error("Invalid destination directory '%s'" % dst)

    root, dirs, files = os.walk(src).next()
    total_size = 0
    for filename in files:
        total_size += os.stat(os.path.join(root, filename)).st_size

    progress = 0
    blocksize = 4096 * 32

    for filename in files:
        srcfile = os.path.join(root, filename)
        dstfile = os.path.join(dst, filename)
        with open(srcfile, "r") as sf:
            with open(dstfile, "w") as df:
                buf = sf.read(blocksize)
                while len(buf) > 0:
                    df.write(buf)
                    df.flush()
                    progress += len(buf)
                    print "%d/%d" % (progress, total_size)
                    sys.stdout.flush()
                    buf = sf.read(blocksize)
                os.fsync(df.fileno())
    return 0
