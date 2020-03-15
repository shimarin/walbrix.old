#define INIFILE
#include "init.h"

#define PROBE_BOOT_PARTITION_MAX_RETRY 8
#define NEWROOT "/newroot"

void setup(inifile_t ini)
{
  const int debug = ini_bool(ini, ":debug", 0);
  setup_hostname_according_to_inifile(NEWROOT, ini);
  set_generated_hostname_if_not_set(NEWROOT);
  setup_timezone_according_to_inifile(NEWROOT, ini);
  setup_keymap_according_to_inifile(NEWROOT, ini);
  setup_wifi_according_to_inifile(NEWROOT, ini);
}

void init()
{
  const char* datafile = "/mnt/boot/system.dat";
  const char* swapfile = "/mnt/boot/system.swp";
  struct partition_struct partition;
  mount_procdevsys_or_die();

  printf("Determining boot partition...");
  if (search_boot_partition(&partition, PROBE_BOOT_PARTITION_MAX_RETRY) < 0) {
    search_partition_by_fstype_or_die("vfat", &partition, PROBE_BOOT_PARTITION_MAX_RETRY);
  }
  printf("%s\n", partition.device);

  mount_or_die(partition.device, "/mnt/boot", "vfat", MS_RELATIME, "fmask=177,dmask=077");
  mount_ro_loop_or_die("/mnt/boot/system.img", "/mnt/system", 0);

  if (!exists(datafile)) {
    printf("RW layer does not exist. Creating...");fflush(stdout);
    if (create_btrfs_imagefile(datafile, 109*1024*1024) == 0) {
        printf("done.\n");
    } else {
        printf("failed.\n");
        unlink(datafile);
        sync();
        halt();
    }
  }
  btrfs_scan();
  if (mount_rw_loop_btrfs(datafile, "/mnt/rw", 1/*compress*/) != 0) {
    printf("Failed to mount RW layer. Attempting repair.\n");
    repair_btrfs_imagefile(datafile);
    if (mount_rw_loop_btrfs(datafile, "/mnt/rw", 1/*compress*/) != 0) {
      printf("No valid persistent RW layer.\n");
      halt();
    }
  }

  if (!exists(swapfile)) {
    printf("Swapfile does not exist. Creating...");fflush(stdout);
    if (create_swapfile(swapfile, 1024L*1024*1024) == 0) {
      printf("done.\n");
    } else {
      printf("failed.\n");
      unlink(swapfile);
    }
  }

  if (is_file(swapfile)) {
    printf("Activating swap...\n");
    activate_swap(swapfile);
  }

  mount_overlay_or_die("/mnt/system", "/mnt/rw/root", "/mnt/rw/work", NEWROOT);
  mount_or_die("tmpfs", NEWROOT"/run", "tmpfs", MS_NODEV|MS_NOSUID|MS_STRICTATIME, "mode=755");

  move_mount_or_die("/mnt/boot", NEWROOT"/run/initramfs/boot");
  move_mount_or_die("/mnt/system", NEWROOT"/run/initramfs/ro");
  move_mount_or_die("/mnt/rw", NEWROOT"/run/initramfs/rw");

  process_inifile(NEWROOT"/run/initramfs/boot/system.ini", setup);

  setup_initramfs_shutdown(NEWROOT);

  switch_root_or_die(NEWROOT);
}

void shutdown()
{
  mkdir_p("/mnt");
  if (move_mount("/oldroot/run", "/mnt") == 0) {
    printf("Unmounting filesystems...\n");
    umount_recursive("/oldroot");
    umount_recursive("/mnt/initramfs/ro");
    umount_recursive("/mnt/initramfs/rw");
    umount_recursive("/mnt");
  }
}
