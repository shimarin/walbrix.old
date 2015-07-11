import argparse,fcntl,os,subprocess,shutil,contextlib
import version,create_install_disk

LOCK_FILE="/.overlay/.lock" # Walbrix's initramfs creates this lock file when system boots
BOOT_PARTITION="/.overlay/boot"
SYSTEM_IMAGE=BOOT_PARTITION + "/walbrix"

@contextlib.contextmanager
def file_lock(lockfile):
    with open(LOCK_FILE) as f:
        fcntl.flock(f,fcntl.LOCK_EX)
        try:
            yield
        finally:
            fcntl.flock(f,fcntl.LOCK_UN)

@contextlib.contextmanager
def rw_mount(mountpoint):
    subprocess.check_call(["mount","-o","rw,remount",mountpoint])
    try:
        yield
    finally:
        print "Syncing..."
        subprocess.check_call(["mount","-o","ro,remount",mountpoint])

def upgrade_efi_xen():
    print "Extracting EFI Xen image..."
    with create_install_disk.tempmount(SYSTEM_IMAGE, "-o ro,loop", "squashfs") as squashfs:
        shutil.copy("%s/x86_64/usr/lib64/efi/xen.efi" % squashfs, "%s/EFI/Walbrix/xen.new" % BOOT_PARTITION)
        shutil.copy("%s/x86_64/boot/kernel" % squashfs, "%s/EFI/Walbrix/kernel.new" % BOOT_PARTITION)
        shutil.copy("%s/x86_64/boot/initramfs" % squashfs, "%s/EFI/Walbrix/initramfs.new" % BOOT_PARTITION)
    shutil.move("%s/EFI/Walbrix/xen.new" % BOOT_PARTITION, "%s/EFI/Walbrix/xen.efi" % BOOT_PARTITION)
    shutil.move("%s/EFI/Walbrix/kernel.new" % BOOT_PARTITION, "%s/EFI/Walbrix/kernel" % BOOT_PARTITION)
    shutil.move("%s/EFI/Walbrix/initramfs.new" % BOOT_PARTITION, "%s/EFI/Walbrix/initramfs" % BOOT_PARTITION)

def run(specified_version = None): # None == latest stable
    print "Checking update info..."
    release_info = create_install_disk.get_release_info(specified_version)

    available_version = release_info["version"]
    print "Available version: %s" % available_version

    if not os.path.isfile(SYSTEM_IMAGE): raise Exception("System image file(%s) does not exist." % SYSTEM_IMAGE)
    current_version = version.read(SYSTEM_IMAGE)["WALBRIX_VERSION"]
    print "Currently installed version: %s" % current_version

    if available_version == current_version:
        print "No need to update."
        return

    print "Locking boot partition..."
    with file_lock(LOCK_FILE):
        with rw_mount(BOOT_PARTITION):
            print "Downloading the system image..."
            subprocess.check_call(["wget","-O",SYSTEM_IMAGE + ".new", release_info["image_url"]])
            shutil.move(SYSTEM_IMAGE, SYSTEM_IMAGE + ".old") # rename system image currently running
            shutil.move(SYSTEM_IMAGE + ".new",SYSTEM_IMAGE)
            if os.path.isdir("%s/EFI/Walbrix" % BOOT_PARTITION): upgrade_efi_xen()

    print "Done. System must be restarted to take effects."

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("version", type=str, nargs='?', help="version string")

    args = parser.parse_args()
    run(args.version)
