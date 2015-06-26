# -*- coding: utf-8 -*-
'''
@author: shimarin
'''

import os,shutil
import system
import cli.create_install_disk

usage = "isofile zipfile"

def setupOptions(parser):
    pass

def run(options, args):
    if len(args) < 2: raise cli.Error("Insufficient parameters.")

    src = args[0]
    dst = args[1]

    s = system.getSystem()
    if s.isBlockSpecial(src):
        option = "ro"
    else:
        option = "ro,loop"
        
    tmpdir = "%s.tmp" % dst
    os.mkdir(tmpdir)

    with s.temporaryMount(src, None, option) as cdrom:
        cli.create_install_disk.copy_files(cdrom, tmpdir)

    #s.installGrubEFI(tmpdir)
    s.execShell("cd %s && zip -r ../%s ." % (tmpdir, dst))
    shutil.rmtree(tmpdir)
