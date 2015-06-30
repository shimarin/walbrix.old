import argparse,array,fcntl,glob,os,subprocess,shutil,struct,sys,tempfile

DEFAULT_SYSTEM_IMAGE="walbrix.squashfs"
MINIMUM_DISK_SIZE_IN_GB=1

BLKGETSIZE=0x1260
BLKGETSIZE64=0x80081272
BLKSSZGET=0x1268

def ioctl_read_uint32(fd, req):
    buf = array.array('c', [chr(0)] * 4)
    fcntl.ioctl(fd, req, buf)
    return struct.unpack('I',buf)[0]

def ioctl_read_uint64(fd, req):
    buf = array.array('c', [chr(0)] * 8)
    fcntl.ioctl(fd, req, buf)
    return struct.unpack('L',buf)[0]

def get_device_capacity(device):
    entire_size_in_bytes = None
    logical_sector_size = None
    try:
        fd = os.open(device, os.O_RDONLY)
        logical_sector_size = ioctl_read_uint32(fd, BLKSSZGET)
        try:
            entire_size_in_bytes = ioctl_read_uint64(fd, BLKGETSIZE64)
        except IOError as e: # Some platform doesn't support BLKGETSIZE64
            if e.errno in (errno.EINVAL,errno.ENOTTY):
                entire_size_in_bytes = ioctl_read_uint32(fd, BLKGETSIZE) * logical_sector_size
            else: raise
    finally:
        os.close(fd)
    return (entire_size_in_bytes, logical_sector_size)

def execute_parted_command(device, command):
    subprocess.check_call(["parted","--script",device,command])
    
def sync_udev():
    subprocess.check_call(["udevadm","settle"])

def get_partition(device, number):
    disk_rdev = os.stat(device).st_rdev
    for partition in glob.glob("/sys/dev/block/%d:%d/*/partition" % (os.major(disk_rdev), os.minor(disk_rdev))):
        if int(open(partition, "r").read().strip()) == number:
            rdev = open(os.path.join(os.path.dirname(partition), "dev"), "r").read().strip()
            return os.path.normpath(os.path.join("/dev/block",os.readlink("/dev/block/%s" % rdev)))
    raise Exception("Partition (%s #%d) is not recognized by system", (device, number))

def run(image, device):
    if not os.path.isfile(image): raise Exception("System image file(%s) does not exist." % image)

    device_size, sector_size = get_device_capacity(device)
    device_size_in_gb = float(device_size) / 1024**3
    if device_size_in_gb < MINIMUM_DISK_SIZE_IN_GB: raise Exception("Insufficient device capacity. %.1fGiB required(%.1fGiB)" % (MINIMUM_DISK_SIZE_IN_GB, device_size_in_gb))

    subprocess.check_call(["lsblk","-d","-o","KNAME,VENDOR,MODEL,SIZE",device])
    if raw_input("Are you sure to destroy all data on %s? ('yes' if sure): " % device) != "yes": return False

    bios_compatible = (sector_size == 512 and device_size <= 2199023255552) # 512 * 2**32

    # create partition table
    execute_parted_command(device, "mklabel %s" % ("msdos" if bios_compatible else "gpt"))

    # create boot partition
    execute_parted_command(device, "mkpart primary 1MiB -1")
    execute_parted_command(device, "toggle 1 boot")
    if bios_compatible: subprocess.check_call(["sfdisk","-q","--change-id",device,"1","ef"])

    # wait for udev to refresh partition info
    sync_udev()

    boot_partition = get_partition(device, 1)

    # format boot partition
    subprocess.check_call(["mkfs.vfat","-F","32",boot_partition])
    # get boot partition uuid
    boot_partition_uuid = subprocess.check_output(["blkid","-o","value","-s","UUID",boot_partition]).strip()

    tmpdir = tempfile.mkdtemp()
    try:
        subprocess.check_call(["mount","-t","vfat",boot_partition,tmpdir])
        try:
            # install bootloader
            os.mkdir("%s/boot" % tmpdir)
            os.makedirs("%s/EFI/BOOT" % tmpdir)

            if bios_compatible: subprocess.check_call(["grub2-install","--target=i386-pc","--recheck","--boot-directory=%s/boot" % tmpdir,device])
            subprocess.check_call(["grub2-mkimage","-o","%s/EFI/BOOT/bootx64.efi" % tmpdir,"-O","x86_64-efi","xfs","fat","part_gpt","part_msdos","normal","linux","echo","all_video","test","multiboot","multiboot2","search","iso9660","gzio","lvm","chain","configfile","cpuid","minicmd","gfxterm","font","terminal"])

            # boot config
            with open("%s/boot/grub/grub.cfg" % tmpdir, "w") as f:
                f.write("loopback loop /walbrix\n")
                f.write("configfile (loop)/grub.cfg\n")
            with open("%s/boot/grub/walbrix.cfg" % tmpdir, "w") as f:
                f.write("set WALBRIX_BOOT=UUID=%s\n" % boot_partition_uuid)
            
            # copy system image
            shutil.copy(image, "%s/walbrix" % tmpdir)
        finally:
            print "Syncing..."
            subprocess.check_call(["umount",tmpdir])
    finally:
        os.rmdir(tmpdir)

    print "Done."
    return True

if __name__ == '__main__':
    if os.getuid() != 0: raise Exception("You must be a root user.")

    parser = argparse.ArgumentParser()
    parser.add_argument("--image", type=str, default=DEFAULT_SYSTEM_IMAGE, help="System image file to install")
    parser.add_argument("device", type=str, help="target device")
    args = parser.parse_args()
    if not run(args.image, args.device): sys.exit(1)

