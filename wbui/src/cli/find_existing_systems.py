# -*- coding: utf-8 -*-
'''
@author: shimarin
'''

import os,sys,struct,subprocess,re

import system
import cli

usage = "[options]"

def setupOptions(parser):
    parser.add_option("-n", "--no-check-filedb", dest="ignore_filedb", action="store_true", help="Ignore /var/db/wb/filedb", default=False)

def check_output(cmd):
    return subprocess.check_output(cmd, shell=True)

def get_kernel_ver(kernel_file):
    if not os.path.isfile(kernel_file): return None
    ver = ""
    with open(kernel_file) as f:
        f.seek(526,0)
        f.seek(struct.unpack('<H', f.read(2))[0] + 0x200,0)
        c = f.read(1)
        limitter = 0
        while limitter < 256 and c and c != '\0':
                ver += c
                limitter += 1
                c = f.read(1)
    return ver.split(' ')[0]

def get_architecture(any_elf_file):
    if not os.path.isfile(any_elf_file): return None
    with open(any_elf_file) as f:
        f.seek(4, 0)
        arch = struct.unpack('B', f.read(1))[0]
    if arch == 1: return 32
    elif arch == 2: return 64
    return None

def run(options, args):
    s = system.getSystem()

    ignore_filedb = options.ignore_filedb

    devices = check_output("lsblk -nr -o KNAME,FSTYPE,MOUNTPOINT,RO,TYPE")
    for line in devices.strip().split('\n'):
        kname,fstype,mount_point,ro,type = line.split(' ')
        if fstype != "vfat" or ro != "0" or mount_point != "": continue
        device_name = "/dev/%s" % kname
        with s.temporaryMount(device_name, None, "ro") as esp:
            kernel_ver = get_kernel_ver("%s/EFI/Walbrix/kernel.64" % esp)
            if kernel_ver == None:
                kernel_ver = get_kernel_ver("%s/EFI/Walbrix/kernel.32" % esp)
            if kernel_ver == None: continue
            if not os.path.isfile("%s/EFI/Walbrix/grubvars.cfg" % esp): continue
            uuid = re.search(r'^ *set +UUID=(.*) *$', open("%s/EFI/Walbrix/grubvars.cfg" % esp).read(),re.MULTILINE)
            if not uuid: continue
            uuid = uuid.group(1)
            try:
                system_volume = check_output("blkid -o device -t UUID=%s" % uuid).strip()
            except subprocess.CalledProcessError:
                continue
        with s.temporaryMount(system_volume, None, "ro") as rootfs:
            architecture = get_architecture("%s/sbin/init" % rootfs)
            if architecture == None: continue
            if ignore_filedb or not os.path.isfile("%s/var/db/wb/filedb" % rootfs): continue

        print "%s\t%s\t%s\t%d" % (device_name, system_volume, kernel_ver, architecture)
