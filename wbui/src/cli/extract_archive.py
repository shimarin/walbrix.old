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

def generateExtractorBySuffix(source, target):
    for k,v in {".tar.gz":["/bin/tar","zxpf","-","--warning=no-timestamp", "-C",target], ".tar.bz2":["/bin/tar","jxpf","-","--warning=no-timestamp","-C",target],".tar.lzma":["/bin/tar","Jxpf","-","--warning=no-timestamp","-C",target],".tar.xz":["/bin/tar","Jxpf","-","--warning=no-timestamp","-C",target]}.iteritems():
        if source.endswith(k): return v
    return ""

def concat(files, outfile):
    for file in files:
        if os.path.isfile(file):
            with open(file, "r") as f:
                outfile.write(f.read())

usage = "[options] sourcefile targetdir"

def setupOptions(parser):
    parser.add_option("-b", "--buffer-size", dest="bufsize", type="int", help="size of buffer (in KB) default=4", default=4)
    parser.add_option("-x", "--exclude-from", dest="exclude_from", help="Exclude file")

def run(options, args):
    if len(args) < 2: raise cli.Error("Insufficient parameters.")

    source = args[0]
    target = args[1]
    bufsize = options.bufsize * 1024
    exclude_from = options.exclude_from
    
    s = system.getSystem()
    
    if not s.isStreamSourceAvailable(source): raise cli.Error("Source file '%s' is not available." % source)
    if not os.path.isdir(target): raise cli.Error("Invalid target dir")

    extractor = generateExtractorBySuffix(source, target)
    if exclude_from != None:
        extractor.append("-X")
        extractor.append(exclude_from)

    i = 0
    tar = subprocess.Popen(extractor, shell=False, stdin=subprocess.PIPE,close_fds=True)

    itstime = time.time()
    try:
        with s.openInputStream(source) as (src, size):
            buf = src.read(bufsize)
            i += len(buf)
            while buf != "":
                newtime = time.time()
                if newtime >= itstime + 0.01:
                    print "%d/%d" % (i, size)
                    sys.stdout.flush()
                    itstime = newtime
                tar.stdin.write(buf)
                buf = src.read(bufsize)
                i+= len(buf)
            print "%d/%d" % (size, size)
            sys.stdout.flush()
    except KeyboardInterrupt:
        tar.terminate()
        tar.stdin.close()
        tar.wait()
        exit(130)

    tar.stdin.close()
    tar.wait()
