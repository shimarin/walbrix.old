# -*- coding: utf-8 -*-
'''
@author: shimarin
'''

import os,shutil,array,fcntl,struct

import system
import cli.setup_entire_disk_efi

BLKGETSIZE=0x1260
BLKSSZGET=0x1268

usage = "isofile device"

def setupOptions(parser):
    pass

def ioctl_read_uint32(fd, req):
    buf = array.array('c', [chr(0)] * 4)
    fcntl.ioctl(fd, req, buf)
    return struct.unpack('I',buf)[0]

def block_device_size(device):
    fd = os.open(device, os.O_RDONLY)
    try:
        logical_sector_size = ioctl_read_uint32(fd, BLKSSZGET)
        return ioctl_read_uint32(fd, BLKGETSIZE) * logical_sector_size
    finally:
        os.close(fd)

def copy_files(src, dst):
    s = system.getSystem()
    print "Copying boot images..."
    if not os.path.isdir("%s/boot" % dst): os.mkdir("%s/boot" % dst)
    s.execShell("cp -a %s/boot/grub %s/boot/" % (src, dst))
    if not os.path.isdir("%s/EFI" % dst): os.mkdir("%s/EFI" % dst)
    s.execShell("cp -a %s/EFI/. %s/EFI/" % (src, dst))
    print "Copying archive images..."
    s.execShell("cp -a %s/*.tar.xz %s/" % (src, dst))
    if os.path.isdir("%s/distfiles" % src):
        print "Copying distfiles..."
        s.execShell("cp -a %s/distfiles %s/" % (src, dst))

def run(options, args):
    if len(args) < 2: raise cli.Error("Insufficient parameters.")

    src = args[0]
    device = args[1]

    s = system.getSystem()
    if s.isBlockSpecial(src):
        size = block_device_size(src)
        option = "ro"
    else:
        size = os.stat(src).st_size
        option = "ro,loop"

    size_in_mib = size / 1024**2 + 128

    if size_in_mib * 1024 ** 2 > block_device_size(device):
        raise cli.Error("Insufficient disk size.")

    s.execShell("lsscsi")
    if raw_input("Are you sure to destroy all data on %s? ('yes' if sure): " % device) != "yes": return 1

    esp = cli.setup_entire_disk_efi.setup(args[1], size_in_mib)["boot_partition"]

    with s.temporaryMount(esp, None) as esp_dir:
        with s.temporaryMount(src, None, option) as cdrom:
            copy_files(cdrom, esp_dir)

        print "Installing boot loader..."
        #s.installGrubEFI(esp_dir)
        if s.isBiosCompatibleDisk(device):
            s.execShell("grub2-install --target=i386-pc --recheck --boot-directory=%s/boot %s" % (esp_dir,device))
