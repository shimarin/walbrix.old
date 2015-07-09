import argparse,fcntl,os,subprocess,shutil
import tempmount

LOCK_FILE="/.overlay/.lock" # Walbrix's initramfs creates this lock file when system boots
BOOT_PARTITION="/.overlay/boot"
SYSTEM_IMAGE=BOOT_PARTITION + "/walbrix"
DOWNLOAD_URL="http://dist.walbrix.net/walbrix"

def upgrade_efi_xen():
    print "Extracting EFI Xen image..."
    with tempmount.apply(SYSTEM_IMAGE, "-o ro,loop", "squashfs") as squashfs:
        shutil.copy("%s/x86_64/usr/lib64/efi/xen.efi" % squashfs, "%s/EFI/Walbrix/xen.new" % BOOT_PARTITION)
        shutil.copy("%s/x86_64/boot/kernel" % squashfs, "%s/EFI/Walbrix/kernel.new" % BOOT_PARTITION)
        shutil.copy("%s/x86_64/boot/initramfs" % squashfs, "%s/EFI/Walbrix/initramfs.new" % BOOT_PARTITION)
    shutil.move("%s/EFI/Walbrix/xen.new" % BOOT_PARTITION, "%s/EFI/Walbrix/xen.efi" % BOOT_PARTITION)
    shutil.move("%s/EFI/Walbrix/kernel.new" % BOOT_PARTITION, "%s/EFI/Walbrix/kernel" % BOOT_PARTITION)
    shutil.move("%s/EFI/Walbrix/initramfs.new" % BOOT_PARTITION, "%s/EFI/Walbrix/initramfs" % BOOT_PARTITION)

def run(args):
    if not os.path.isfile(SYSTEM_IMAGE): raise Exception("System image file(%s) does not exist." % SYSTEM_IMAGE)
    print "Locking boot partition..."
    with open(LOCK_FILE) as f:
        fcntl.flock(f,fcntl.LOCK_EX)
        subprocess.check_call(["mount","-o","rw,remount",BOOT_PARTITION])
        try:
            print "Downloading the latest system image..."
            subprocess.check_call(["wget","-O",SYSTEM_IMAGE + ".new", DOWNLOAD_URL])
            shutil.move(SYSTEM_IMAGE, SYSTEM_IMAGE + ".old") # rename system image currently running
            shutil.move(SYSTEM_IMAGE + ".new",SYSTEM_IMAGE)
            if os.path.isdir("%s/EFI/Walbrix" % BOOT_PARTITION): upgrade_efi_xen()
        finally:
            print "Syncing..."
            subprocess.check_call(["mount","-o","ro,remount",BOOT_PARTITION])
        fcntl.flock(f,fcntl.LOCK_UN)
    print "Done. System must be restarted to take effects."

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    args = parser.parse_args()
    run(args)
