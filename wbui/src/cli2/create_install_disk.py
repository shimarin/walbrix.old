#!/usr/bin/python2.7
import argparse,array,fcntl,glob,os,subprocess,shutil,struct,sys,tempfile,re,json,urllib2,contextlib,time

DEFAULT_UPDATE_INFO_URL="http://update.walbrix.net"
DEFAULT_SYSTEM_IMAGE="/.overlay/boot/walbrix"
MINIMUM_DISK_SIZE_IN_GB=1
MAX_BIOS_FRIENDLY_DISK_SIZE=2199023255552

GRUB_MODULES=["xfs","fat","part_gpt","part_msdos","normal","linux","echo","all_video","test","multiboot","multiboot2","search","iso9660","gzio","lvm","chain","configfile","cpuid","minicmd","gfxterm","font","terminal","squash4","loopback","videoinfo","videotest","png","gfxterm_background"]

def ioctl_read_uint32(fd, req):
    buf = array.array('c', [chr(0)] * 4)
    fcntl.ioctl(fd, req, buf)
    return struct.unpack('I',buf)[0]

def ioctl_read_uint64(fd, req):
    buf = array.array('c', [chr(0)] * 8)
    fcntl.ioctl(fd, req, buf)
    return struct.unpack('L',buf)[0]

def get_device_capacity(device):
    BLKSSZGET=0x1268

    if isinstance(device, tuple): major, minor = device
    else:
        disk_rdev = os.stat(device).st_rdev
        major, minor = (os.major(disk_rdev), os.minor(disk_rdev))

    device_dir = "/sys/dev/block/%d:%d" % (major, minor)

    logical_sector_size = None
    fd = os.open(device, os.O_RDONLY)
    try:
        logical_sector_size = ioctl_read_uint32(fd, BLKSSZGET)
    finally:
        os.close(fd)
    number_of_512b_sectors = int(open("%s/size" % device_dir).read()) # unbelievably, "size" always is based on 512-bytes block no matter what its sector size is.
    return (number_of_512b_sectors * 512, logical_sector_size)

def get_disk_from_partition(partition):
    if isinstance(partition, tuple): major, minor = partition
    else: # expect str
        partition_rdev = os.stat(partition).st_rdev
        major, minor = (os.major(partition_rdev), os.minor(partition_rdev))
    for dev in glob.glob("/sys/dev/block/*/*/dev"):
        if open(dev, "r").read().strip() == "%d:%d" % (major, minor):
            rdev = open(os.path.normpath(os.path.join(os.path.dirname(dev), "../dev")), "r").read().strip()
            return os.path.normpath(os.path.join("/dev/block",os.readlink("/dev/block/%s" % rdev)))
    return None

def partition_belongs_to(partition, disk):
    def is_same_device(device1, device2):
        return os.stat(device1).st_rdev == os.stat(device2).st_rdev

    discovered_disk = get_disk_from_partition(partition)
    if discovered_disk and is_same_device(disk, discovered_disk): return True
    # else
    partition_rdev = os.stat(partition).st_rdev
    for dev in glob.glob("/sys/dev/block/%d:%d/slaves/*/dev" % (os.major(partition_rdev), os.minor(partition_rdev))):
        major, minor = map(lambda x:int(x), open(dev).read().strip().split(':'))
        discovered_disk = get_disk_from_partition((major, minor))
        if discovered_disk and is_same_device(disk, discovered_disk):
            return True
    return False

def get_capacity_string(num_bytes):
    if num_bytes < 1000000: return "<1MB"
    if num_bytes < 1000000000: return "%dMB" % (num_bytes / 1000000)
    if num_bytes < 1000000000000: return "%dGB" % (num_bytes / 1000000000)
    #else
    return "%dTB" % (num_bytes / 1000000000000)

def get_disk_info(device):
    if isinstance(device, tuple): major, minor = device
    else:
        disk_rdev = os.stat(device).st_rdev
        major, minor = (os.major(disk_rdev), os.minor(disk_rdev))
    device_dir = "/sys/dev/block/%d:%d" % (major, minor)
    if not os.path.isdir("%s/device" % device_dir): return None  # Not representing a pysical device

    def read(file):
        filename = os.path.join(device_dir, file)
        if not os.path.isfile(filename): return None
        return open(filename).read().strip()

    rst = {"name":device, "identical_name":"/dev/block/%d:%d" % (major, minor),"device_dir":device_dir, "major":major, "minor":minor, "ro":int(read("ro")),"removable":int(read("removable")),"vendor":read("device/vendor") or read("device/oemid"),"model":read("device/model") or read("device/name")}
    try:
        device_capacity = get_device_capacity(device)
        rst["size"] = device_capacity[0]
        rst["sector_size"] = device_capacity[1]
        rst["bios_compatible"] = rst["sector_size"] == 512 and rst["size"] <= MAX_BIOS_FRIENDLY_DISK_SIZE
    except OSError:
        pass   # e.g. unloaded cd-rom drive

    if "size" in rst: rst["size_str"] = get_capacity_string(rst["size"])

    return rst

def usable_disks(minimum_disk_size = 1000000000):
    DEVICE_NAME_REGEX = re.compile(r'^\/sys\/block\/(.+)\/device$')

    mounted_partitions = filter(lambda x:x.startswith("/dev/"), map(lambda x:x.split()[0], open("/proc/mounts").readlines()))

    rst = []
    for d in glob.glob("/sys/block/*/device"):
        match = DEVICE_NAME_REGEX.match(d)
        if match is None: continue  # it can't happen, though
        device_name = "/dev/" + match.groups()[0]
        disk_info = get_disk_info(device_name)
        if disk_info is None or disk_info["ro"] != 0: continue  # skip R/O device
        if disk_info["removable"] != 0 and not device_name.startswith("/dev/sd"): continue # skip non-/dev/sdX removable device (e.g. /dev/srX)
        if any(partition_belongs_to(x, device_name) for x in mounted_partitions): continue # skip disk contains any mounted partition
        if "size" not in disk_info or disk_info["size"] < minimum_disk_size: continue
        rst.append(disk_info)
    return rst

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

@contextlib.contextmanager
def tempmount(device, options = None, type = "auto"):
    tmpdir = tempfile.mkdtemp()
    try:
        cmdline = ["mount","-t",type]
        if options is not None: cmdline += ["-o",options]
        cmdline += [device,tmpdir]
        subprocess.check_call(cmdline)
        try:
            yield tmpdir
        finally:
            retry = 5
            while retry > 0:
                if subprocess.call(["umount",tmpdir]) == 0: break
                time.sleep(3)
                retry -= 1
    finally:
        os.rmdir(tmpdir)

def print_disk_info(disks):
    row_format ="{:<15} {:>8} {:>12} {:>20} {:>10}"
    print row_format.format("NAME","SIZE","VENDOR","MODEL","BOOT TYPE")
    print "---------------------------------------------------------------------"
    for disk in disks:
        print row_format.format(disk["name"],disk["size_str"],'"' + (disk["vendor"] or "UNKNOWN") + '"','"' + (disk["model"] or "UNKNOWN") + '"',"BIOS+UEFI" if disk["bios_compatible"] else "UEFI")

def print_usable_disks(minimum_disk_size = 1000000000):
    print "Target disk(like /dev/sdX) must be specified.  Usable disks are:"
    print_disk_info(usable_disks(minimum_disk_size))
    print "Disks you're going to use aren't listed above? Unmount them first."

def get_partition_uuid(partition):
    return subprocess.check_output(["blkid","-o","value","-s","UUID",partition]).strip()

def get_release_info(specified_version = None, update_info_url = DEFAULT_UPDATE_INFO_URL): # None == latest stable
    update_info = json.load(urllib2.urlopen(update_info_url))
    if specified_version is None: specified_version = update_info["latest_stable"]
    for v in update_info["releases"]:
        if v["version"] == specified_version: return v
    #else
    raise Exception("No such version: %s" % specified_version)

def search_command(name, altname = None):
    for path in os.environ["PATH"].split(':'):
        fullpath = os.path.join(path, name)
        if os.path.isfile(fullpath): return fullpath
        elif altname is not None:
            fullpath = os.path.join(path, altname)
            if os.path.isfile(fullpath): return fullpath
    return None

def exec_install(device, image = None, yes = False, update_url=DEFAULT_UPDATE_INFO_URL,ins_file=None):
    if image is not None:
        if not os.path.isfile(image): raise Exception("Image file '%s' not found." % image)
    else:
        if os.path.isfile(DEFAULT_SYSTEM_IMAGE): image = DEFAULT_SYSTEM_IMAGE
        else:
            print "System image file not specified. It's going to be downloaded."
            release_info = get_release_info(None, update_url)
            print "Version: %s" % release_info["version"]
            image = release_info["image_url"]
            print "Download URL: %s" % image

    disk_info = get_disk_info(device)
    disk_size = disk_info["size"]
    bios_compatible = disk_info["bios_compatible"]

    if disk_size < MINIMUM_DISK_SIZE_IN_GB * 1000000000: raise Exception("Insufficient device capacity. %.1fGB required(%.1fGB)" % (MINIMUM_DISK_SIZE_IN_GB, disk_size / 1000000000.0))
    print_disk_info([disk_info])
    if not yes and raw_input("Are you sure to destroy all existing data on %s? ('yes' if sure): " % device) != "yes": return None

    # create partition table
    execute_parted_command(device, "mklabel %s" % ("msdos" if bios_compatible else "gpt"))

    # create boot partition
    execute_parted_command(device, "mkpart primary 1MiB %s" % ("-1" if disk_size <= MAX_BIOS_FRIENDLY_DISK_SIZE else "2TiB"))
    execute_parted_command(device, "set 1 boot on")
    if bios_compatible: execute_parted_command(device, "set 1 esp on")

    # wait for udev to refresh partition info
    sync_udev()

    boot_partition = get_partition(device, 1)

    # format boot partition
    subprocess.check_call([search_command("mkfs.vfat","mkfs.msdos"),"-F","32",boot_partition])
    # get boot partition uuid
    boot_partition_uuid = get_partition_uuid(boot_partition)

    with tempmount(boot_partition, None, "vfat") as tmpdir:
        # install bootloader
        os.makedirs("%s/boot/grub" % tmpdir)
        os.makedirs("%s/EFI/BOOT" % tmpdir)

        if bios_compatible: subprocess.check_call([search_command("grub2-install","grub-install"),"--target=i386-pc","--recheck","--boot-directory=%s/boot" % tmpdir,device])
        subprocess.check_call([search_command("grub2-mkimage","grub-mkimage"),"-p","/boot/grub" "-o","%s/EFI/BOOT/bootx64.efi" % tmpdir,"-O","x86_64-efi"] + GRUB_MODULES)

        # boot config
        with open("%s/boot/grub/grub.cfg" % tmpdir, "w") as f:
            f.write("loopback loop /walbrix\n")
            f.write("source (loop)/install.cfg\n")
        with open("%s/boot/grub/walbrix.cfg" % tmpdir, "w") as f:
            f.write("set WALBRIX_BOOT=UUID=%s\n" % boot_partition_uuid)

        # copy system image
        save_image_file_to = "%s/walbrix" % tmpdir
        if image.startswith("http://") or image.startswith("https://"):
            subprocess.check_call(["wget","-O",save_image_file_to,image])
        else:
            shutil.copy(image, save_image_file_to)

        # copy ins file if specified
        if ins_file is not None:
            shutil.copy(ins_file, save_image_file_to + ".ins")

        print "Syncing..."

    print "Done."
    return boot_partition

def copy_sources(partition):
    if not os.path.isdir("/usr/portage/distfiles"): raise Exception("Portage doesn't exist(/usr/portage/distfiles)")
    print "Cleaning distfiles..."
    subprocess.check_call(["eclean-dist"])
    with tempmount(partition, None, "vfat") as tmpdir:
        print "Archiving portage tree..."
        subprocess.check_call(["tar","Jcf","%s/portage.tar.xz" % tmpdir,"--exclude=portage/metadata/cache","--exclude=portage/packages","--exclude=portage/distfiles","-C","/usr","portage"])
        print "Copying distfiles...."
        subprocess.check_call(["cp","-r","/usr/portage/distfiles","%s/" % tmpdir])
        print "Syncing..."

def check_prereqs():
    arch = os.uname()[4]
    if arch != "x86_64": print "WARNING: The system architecture(%s) is not x86_64" % arch
    if search_command("parted") is None: print "WARNING: parted command is missing"
    if search_command("udevadm") is None: print "WARNING: udevadm command is missing"
    if search_command("mkfs.fat", "mkfs.msdos") is None: print "WARNING: mkfs.fat(mkfs.msdos) command is missing"
    if search_command("wget") is None: print "WARNING: wget command is missing (You prefer curl instead? sorry.)"
    if search_command("blkid") is None: print "WARNING: blkid command is missing"
    if search_command("grub2-mkimage","grub-mkimage") is None: print "WARNING: grub2-mkimage(grub-mkimage) command is missing"
    if search_command("grub2-install","grub-install") is None: print "WARNING: grub2-install(grub-install) command is missing"

if __name__ == '__main__':
    if os.getuid() != 0: raise Exception("You must be a root user.")

    parser = argparse.ArgumentParser()
    parser.add_argument("--image", type=str, help="System image file to install")
    parser.add_argument("--yes", "-y", action="store_true", help="Proceed without confirmation")
    parser.add_argument("--sources", action="store_true", help="Copy portage tree")
    parser.add_argument("--update-url", type=str, default=DEFAULT_UPDATE_INFO_URL, help="Update info URL")
    parser.add_argument("--ins-file", type=str, help="ins file")
    parser.add_argument("device", type=str, nargs='?', help="Target device")
    args = parser.parse_args()

    check_prereqs()

    if args.device is None:
        print_usable_disks(MINIMUM_DISK_SIZE_IN_GB * 1000000000)
        sys.exit(1)
    #else
    boot_partition = exec_install(args.device, args.image, args.yes, args.update_url,args.ins_file)
    if boot_partition is None: sys.exit(1)

    if args.sources:
        copy_sources(boot_partition)
