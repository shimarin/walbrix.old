import argparse,os,subprocess,shutil,sys,stat
import magic
import create_install_disk,fbinfo,boot_vga_info

MINIMUM_DISK_SIZE_IN_GB=3.5
DEFAULT_XEN_VGA="gfx-640x480x32"
DRM_MODULE_BLACKLIST=["mgag200"]

def shutdown_vgs():
    subprocess.check_call(["vgchange","-an"], close_fds=True)

def determine_xen_vga_mode():
    # https://github.com/wbrxcorp/walbrix/issues/20
    info = fbinfo.apply()
    if info is None or len(info) == 0: return DEFAULT_XEN_VGA
    if info[0] not in ["EFI VGA", "VESA VGA"]: return None
    return "gfx-%dx%dx%d" % (info[1],info[2],info[3])

def is_kms_compatible_system():
    info = boot_vga_info.get_boot_vga_info()
    return info is not None and info.get("modeset") == True and info.get("module") not in DRM_MODULE_BLACKLIST

def run(device, image, yes = False, no_bios = False, xen_vga = None): # image can be device like /dev/sr0
    if not os.path.exists(image): raise Exception("System image file(%s) does not exist." % image)

    disk_info = create_install_disk.get_disk_info(device)
    device_size = disk_info["size"]

    device_size_in_gb = float(device_size) / 1024**3
    if device_size_in_gb < MINIMUM_DISK_SIZE_IN_GB: raise Exception("Insufficient device capacity. %.1fGiB required(%.1fGiB)" % (MINIMUM_DISK_SIZE_IN_GB, device_size_in_gb))

    if not yes:
        create_install_disk.print_disk_info([disk_info])
        if raw_input("Are you sure to destroy all data on %s? ('yes' if sure): " % device) != "yes": return False

    shutdown_vgs() # deactivate all VGs as target device might have belonged to some of them

    bios_compatible = not no_bios and disk_info["bios_compatible"]

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
    if xen_vga is None and not is_kms_compatible_system(): xen_vga="DETECT"
    if xen_vga == "DETECT": xen_vga = determine_xen_vga_mode()

    with create_install_disk.tempmount(boot_partition, "rw", "vfat") as tmpdir:
        # install bootloader
        os.makedirs("%s/boot/grub" % tmpdir)
        os.makedirs("%s/EFI/BOOT" % tmpdir)

        if bios_compatible: subprocess.check_call(["grub-install","--target=i386-pc","--recheck","--boot-directory=%s/boot" % tmpdir,device])
        subprocess.check_call(["grub-mkimage","-p","/boot/grub","-o","%s/EFI/BOOT/bootx64.efi" % tmpdir,"-O","x86_64-efi"] + create_install_disk.GRUB_MODULES)

        # boot config
        with open("%s/boot/grub/grub.cfg" % tmpdir, "w") as f:
            f.write("loopback loop /walbrix\n")
            f.write("source (loop)/grub.cfg\n")
        with open("%s/boot/grub/walbrix.cfg" % tmpdir, "w") as f:
            #f.write("set WALBRIX_BOOT=UUID=%s\n" % boot_partition_uuid)
            f.write("#set WALBRIX_DOM0_MEM=1024M\n")
            f.write("#set WALBRIX_DOM0_MODEL=pvh\n")
            f.write("#set WALBRIX_GRUB_DEFAULT=0\n")
            f.write("#set WALBRIX_GRUB_TIMEOUT=3\n")
            f.write("#set WALBRIX_PCI_PASSTHROUGH_DEVICES=(AA:BB.C)(XX:YY.Z)\n")
            if xen_vga: f.write("set WALBRIX_XEN_VGA=%s\n" % xen_vga)
            else: f.write("#set WALBRIX_XEN_VGA=gfx-640x480x32\n")

        # copy system image
        print "Installing Walbrix..."

        image_dest = "%s/walbrix" % tmpdir
        if magic.from_buffer(open(image).read(65536)).startswith("ISO 9660"):
            subprocess.check_call(["iso-read","-i",image,"-e","/walbrix","-o",image_dest])
            if stat.S_ISBLK(os.stat(device)[stat.ST_MODE]):
                print "Done. Ejecting install disk..."
                subprocess.call(["eject",image])
        else:
            shutil.copy(image, image_dest)
        subprocess.call(["sync"])

        print "Installing EFI xen..."
        os.makedirs("%s/EFI/Walbrix" % tmpdir)

        with create_install_disk.tempmount(image_dest, "-o ro,loop", "squashfs") as squashfs:
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
    profile_volume = "/dev/%s/profile" % vgname
    subprocess.check_call(["mkfs.xfs","-q",profile_volume])

    # initialize profile volume
    with create_install_disk.tempmount(profile_volume, "rw", "xfs") as tempdir:
        # create profile partition marker
        with open(os.path.join(tempdir, boot_partition_uuid), "w") as f:
            f.write("This is a marker file which indicates that this partition is the profile partition for a boot partition specifically UUID'ed as its filename")
        # install ins file if exists
        ins_file = image + ".ins"
        if os.path.isfile(ins_file):
            rw_layer = os.path.join(tempdir,"root")
            os.mkdir(rw_layer)
            subprocess.call(["tar","xvf",ins_file,"-C",rw_layer])
    print "Done."
    return True

def detect_install_image():
    image = create_install_disk.DEFAULT_SYSTEM_IMAGE
    if os.path.isfile(image):
        return image
    #else
    # search CD-ROM
    for line in subprocess.check_output(["lsblk","-nd","--raw","-o","NAME,FSTYPE"]).splitlines():
        line = line.split()
        if len(line) > 1 and line[1] == "iso9660":
            return "/dev/%s" % line[0]
    raise Exception("No usable install image")

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--image", type=str, help="System image file to install")
    parser.add_argument("--no-bios", action="store_true", help="Don't install bootloader for BIOS(UEFI only)")
    parser.add_argument("--yes", "-y", action="store_true", help="Proceed without confirmation")
    parser.add_argument("--xen-vga", type=str, nargs='?', const="DETECT", help="Specify Xen's vga= option")
    parser.add_argument("device", type=str, nargs='?', help="target device")
    args = parser.parse_args()
    device = args.device
    if device is None:
        usable_disks = create_install_disk.usable_disks(int(MINIMUM_DISK_SIZE_IN_GB * 1000000000))
        num_disk = len(usable_disks)
        if num_disk < 1:
            print "There are not usable disks on this system."
            sys.exit(1)
        elif num_disk > 1:
            print "Target disk(typically /dev/sda) must be specified.  Usable disks are:"
            create_install_disk.print_disk_info(usable_disks)
            sys.exit(1)
        else:
            device = usable_disks[0]["name"]
    image = args.image if args.image is not None else detect_install_image()

    if not run(device, image, args.yes, args.no_bios, args.xen_vga): sys.exit(1)
