# -*- coding: utf-8 -*-
'''
@author: shimarin
'''

import os,sys,json

import system
import cli

usage = "[options] device"

def setupOptions(parser):
    parser.add_option("-s", "--partiion-size", dest="partition_size", type="int", help="Size of boot partition in MiB.", default=512)
    parser.add_option("-f", "--filesystem", dest="filesystem", help="Filesystem type to use(Default=xfs)", default="xfs")
    parser.add_option("-g", "--force-gpt", dest="force_gpt", action="store_true", help="Force to use GPT partition table regardless disk size", default=False)
    parser.add_option("--no-vg", dest="no_vg", action="store_true", help="Don't create a VG", default=False)

def setup_lvm(device, partition_starts, filesystem):
    s = system.getSystem()

    s.createPrimaryPartition(device, "%dMiB" % partition_starts, "-1")
    s.setLVMFlag(device, 2)
    s.syncUdev()

    lvmPartition = s.getPartition(device, 2)

    with s.suppressStdout():
        s.reloadVolumeGroups()
        s.createPhysicalVolume(lvmPartition)
        vgname = s.getVolumeGroupNameCandidate("wbvg", 99)

    if vgname is None: raise cli.Error("Could not determine vg name")

    fs = s.getFilesystem(filesystem)
    with s.suppressStdout():
        s.createVolumeGroup(vgname, lvmPartition, "@wbvg", "@wbpv")
        root_partition = s.createLogicalVolume(vgname, "system", 1, "@wbsystem")
        s.waitForDevice(root_partition)
        fs.mkfs(root_partition)

    return root_partition

def setup(device, partition_size=512, force_gpt=False, no_vg=True, filesystem="xfs"):
    s = system.getSystem()

    if not s.isBlockSpecial(device): raise cli.Error("Invalid device is specified." % device)

    with s.suppressStdout():
        s.deactivateVolumeGroups(False)

    bios_compatible = False

    if not force_gpt and s.isBiosCompatibleDisk(device): bios_compatible = True

    if bios_compatible:
        s.createFdiskPartitionTable(device)
    else:
        s.createEFIPartitionTable(device)

    logical_sector_size = s.getLogicalSectorSize(device)
    number_of_sectors = partition_size * 1024 ** 2 / logical_sector_size
    one_mb_boundary = 1048576 / logical_sector_size

    s.createPrimaryPartition(device, "1MiB", "%dMiB" % partition_size)
    s.toggleBootFlag(device, 1)
    if not s.syncUdev():
        raise cli.Error("Failed to sync udev")

    boot_partition = s.getPartition(device, 1)
    with s.suppressStdout():
        if bios_compatible:
            s.execShell("sfdisk -q --change-id %s 1 ef" % device)
        if s.execShell("mkfs.vfat -F 32 %s" % boot_partition) != 0:
            raise cli.Error("Failed to mkfs.vfat on ESP(%s)" % boot_partition)

    with s.temporaryMount(boot_partition) as boot_dir:
        os.mkdir("%s/boot" % boot_dir)
        os.makedirs("%s/EFI/BOOT" % boot_dir)
        os.makedirs("%s/EFI/Walbrix" % boot_dir)

    root_partition = None if no_vg else setup_lvm(device, partition_size, filesystem)

    return {"boot_partition":boot_partition,"root_partition":root_partition,"bios_compatible":bios_compatible}

def run(options, args):
    if len(args) < 1: raise cli.Error("Insufficient parameters.")

    json.dump(setup(args[0], options.partition_size, options.force_gpt, options.no_vg, options.filesystem),sys.stdout)
    print ""
