import argparse,glob,os,subprocess,shutil,sys,tempfile
import create_install_disk,fbinfo

MINIMUM_DISK_SIZE_IN_GB=3.5
DEFAULT_XEN_VGA="gfx-640x480x32"

def shutdown_vgs():
    subprocess.check_call(["vgchange","-an"], close_fds=True)

def determine_xen_vga_mode():
    # https://github.com/wbrxcorp/walbrix/issues/20
    info = fbinfo.apply()
    if info is None or len(info) == 0: return DEFAULT_XEN_VGA
    if info[0] not in ["EFI VGA", "VESA VGA"]: return None
    return "gfx-%dx%dx%d" % (info[1],info[2],info[3])

def run(device, image, no_bios = False, xen_vga = None):
    if not os.path.isfile(image): raise Exception("System image file(%s) does not exist." % image)

    disk_info = create_install_disk.get_disk_info(device)
    device_size = disk_info["size"]

    device_size_in_gb = float(device_size) / 1024**3
    if device_size_in_gb < MINIMUM_DISK_SIZE_IN_GB: raise Exception("Insufficient device capacity. %.1fGiB required(%.1fGiB)" % (MINIMUM_DISK_SIZE_IN_GB, device_size_in_gb))

    create_install_disk.print_disk_info([disk_info])
    if raw_input("Are you sure to destroy all data on %s? ('yes' if sure): " % device) != "yes": return False

    shutdown_vgs() # deactivate all VGs as target device might have belonged to some of them
    
    bios_compatible = disk_info["bios_compatible"]

    # create partition table
    create_install_disk.execute_parted_command(device, "mklabel %s" % ("msdos" if bios_compatible else "gpt"))

    # create boot partition
    create_install_disk.execute_parted_command(device, "mkpart primary 1MiB 2GiB")
    create_install_disk.execute_parted_command(device, "set 1 boot on")
    if bios_compatible: create_install_disk.execute_parted_command(device, "set 1 esp on")

    # create lvm physical volume (for profile and virtual machines)
    create_install_disk.execute_parted_command(device, "mkpart primary 2GiB, -1")

    # wait for udev to refresh partition info
    create_install_disk.sync_udev()

    boot_partition = create_install_disk.get_partition(device, 1)
    physical_volume = create_install_disk.get_partition(device, 2)

    # format boot partition
    subprocess.check_call(["mkfs.vfat","-F","32",boot_partition])
    # get boot partition uuid
    boot_partition_uuid = create_install_disk.get_partition_uuid(boot_partition)

    # setup lvm
    vgname = "wbvg-" + boot_partition_uuid
    lvname = "profile"
    shutdown_vgs() # this needs to be done again right before pvcreate
    subprocess.check_call(["pvcreate","-ffy",physical_volume], close_fds=True)
    create_install_disk.execute_parted_command(device, "set 2 lvm on")

    subprocess.check_call(["vgcreate","--yes","--addtag=@wbvg",vgname, physical_volume], close_fds=True)
    subprocess.check_call(["lvcreate","--yes","--addtag=@wbprofile","-n",lvname,"-L","1G",vgname], close_fds=True)
    create_install_disk.sync_udev()

    # detect vga mode if necessary
    if xen_vga == "DETECT": xen_vga = determine_xen_vga_mode()
    
    with create_install_disk.tempmount(boot_partition, "rw", "vfat") as tmpdir:
        # install bootloader
        os.makedirs("%s/boot/grub" % tmpdir)
        os.makedirs("%s/EFI/BOOT" % tmpdir)

        if bios_compatible: subprocess.check_call(["grub2-install","--target=i386-pc","--recheck","--boot-directory=%s/boot" % tmpdir,device])
        subprocess.check_call(["grub2-mkimage","-o","%s/EFI/BOOT/bootx64.efi" % tmpdir,"-O","x86_64-efi"] + create_install_disk.GRUB_MODULES)

        # boot config
        with open("%s/boot/grub/grub.cfg" % tmpdir, "w") as f:
            f.write("loopback loop /walbrix\n")
            f.write("source (loop)/grub.cfg\n")
        with open("%s/boot/grub/walbrix.cfg" % tmpdir, "w") as f:
            f.write("set WALBRIX_BOOT=UUID=%s\n" % boot_partition_uuid)
            if xen_vga is not None: f.write("set WALBRIX_XEN_VGA=%s\n" % xen_vga)
            
        # copy system image
        print "Installing Walbrix..."
        shutil.copy(image, "%s/walbrix" % tmpdir)
        subprocess.call(["sync"])

        print "Installing EFI xen..."
        os.makedirs("%s/EFI/Walbrix" % tmpdir)

        with create_install_disk.tempmount(image, "-o ro,loop", "squashfs") as squashfs:
            shutil.copy("%s/x86_64/usr/lib64/efi/xen.efi" % squashfs, "%s/EFI/Walbrix/xen.efi" % tmpdir)
            shutil.copy("%s/x86_64/boot/kernel" % squashfs, "%s/EFI/Walbrix/kernel" % tmpdir)
            shutil.copy("%s/x86_64/boot/initramfs" % squashfs, "%s/EFI/Walbrix/initramfs" % tmpdir)

        with open("%s/EFI/Walbrix/xen.cfg" % tmpdir, "w") as f:
            f.write("[global]\ndefault=Walbrix\n\n")
            f.write("[Walbrix]\n")
            f.write("options=dom0_mem=512M,max:512M\n")
            f.write("kernel=kernel dolvm domdadm scandelay edd=off walbrix.boot=UUID=%s splash=silent,theme:wb console=tty1 quiet nomodeset\n" % boot_partition_uuid)
            f.write("ramdisk=initramfs\n")

        subprocess.call(["sync"])

    # format profile volume
    subprocess.check_call(["mkfs.xfs","-q","/dev/%s/profile" % vgname])
    print "Done."
    return True

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--image", type=str, default=create_install_disk.DEFAULT_SYSTEM_IMAGE, help="System image file to install")
    parser.add_argument("--no-bios", action="store_true", help="Don't install bootloader for BIOS(UEFI only)")
    parser.add_argument("--xen-vga", type=str, nargs='?', const="DETECT", help="Specify Xen's vga= option")
    parser.add_argument("device", type=str, nargs='?', help="target device")
    args = parser.parse_args()
    if args.device is None:
        create_install_disk.print_usable_disks()
        sys.exit(1)
    if not run(args.device, args.image, args.no_bios, args.xen_vga): sys.exit(1)
