# -*- coding: utf-8 -*-
'''
@author: shimarin
'''

import os
import sys
import mmap
import time
from optparse import OptionParser, OptionValueError

import system
import cli

#cli.register(__name__.rsplit(".",1)[-1], "Disk benchmark")

usage = "[options] vgname"

def setupOptions(parser):
    pass

def progress(x, y):
    print "%d/%d" % (x, y)
    sys.stdout.flush()

def sequential_write(device):
    zero = os.open("/dev/zero", os.O_RDONLY)
    try:
        m = mmap.mmap(zero, 1024 * 1024, prot=mmap.PROT_READ)
        try:
            fd = os.open(device, os.O_SYNC|os.O_DIRECT|os.O_WRONLY)
            try:
                written = 0
                start_time = time.time()
                for i in range(0, 1024):
                    written += os.write(fd, m)
                end_time = time.time()
            finally:
                os.close(fd)
        finally:
            m.close()
    finally:
        os.close(zero)
    print "Sequential write: %.1fMB/s" % (float(written) / 1000 / 1000 / (end_time - start_time))

def sequential_read(device):
    fd = os.open(device, os.O_SYNC|os.O_RDONLY)
    try:
        read = 0
        start_time = time.time()
        for i in range(0, 1024):
            read += len(os.read(fd, 1024 * 1024))
        end_time = time.time()
    finally:
        os.close(fd)
    print "Sequential read: %.1fMB/s" % (float(read) / 1000 / 1000 / (end_time - start_time))

def run(options, args):
    if len(args) < 1: raise cli.Error("Insufficient parameters.")

    vgname = args[0]
    s = system.getSystem()
    device = s.createLogicalVolume(vgname, "_WBDISKBENCH_", 1)
    try:
        print "Testing sequential write..."
        sequential_write(device)
        print "Testing sequential read..."
        sequential_read(device)
    finally:
        s.removeLogicalVolume(device)
