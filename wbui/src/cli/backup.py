'''
Created on 2011/05/23

@author: shimarin
'''

import sys
import subprocess

import cli
import system

usage = "[options] device_name"

def backupRaw(deviceName):
    pass

def backupTar(deviceName):
    s = system.getSystem()
    with s.temporaryMount(deviceName, None, "ro") as tmpdir:
        cmd = "tar cvpf - -C %s ." % tmpdir 
        with s.openProcessForInput(cmd) as tar:
            buf = tar.read(1024)
            while buf != "":
                sys.stdout.write(buf)
                buf = tar.read(1024)

def setupOptions(parser):
    parser.add_option("-s", "--snapshot-size", dest="snapshot_size", type="int", help="size of snapshot of the logical volume(in gigabytes), 0 to disable using snapshot. default=1", default=1)

def run(options, args):
    if len(args) < 1: raise cli.Error("Device name must be specified.")

    deviceName = args[0]
    snapshotSize = options.snapshot_size

    s = system.getSystem()
    with s.openProcessForInput("lsblk -nr -o MAJ:MIN,FSTYPE %s" % deviceName) as lsblk:
        line = lsblk.readline()
        if not line: raise cli.Error("Device '%s' doesn't exist or may not be a block device." % deviceName)
        splitted = line.split(" ")
        devNum = splitted[0]
        fstype = splitted[1].strip() if len(splitted) > 1 else None
        if fstype == "": fstype = None
    
    backupFunc = backupRaw if fstype is None else backupTar
    print >> sys.stderr, "Backup type:%s" % ("raw" if backupFunc == backupRaw else "tar")

    useSnapshot = (deviceName in (x.strip() for x in subprocess.check_output("lvs --noheadings -o lv_path --unquoted", shell=True, close_fds=True).split('\n') if x != "") and snapshotSize > 0)

    if useSnapshot:
        with s.openSnapshot(deviceName, snapshotSize) as snapshot:
            print >> sys.stderr, "Using snapshot:%s" % snapshot
            backupFunc(snapshot)
    else:
        backupFunc(deviceName)

    print >>sys.stderr, "Done."
