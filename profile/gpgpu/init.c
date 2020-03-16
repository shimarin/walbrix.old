#define INIFILE
#include "init.h"

#define PROBE_BOOT_PARTITION_MAX_RETRY 8
#define NEWROOT "/newroot"

void setup(inifile_t ini)
{
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

  if (is_file("/mnt/boot/system.cur")) {
    if (rename("/mnt/boot/system.cur", "/mnt/boot/system.old") == 0) {
      printf("Previous system image preserved.\n");
    }
  }

  if (!exists(datafile) && get_free_disk_space("/mnt/boot") >= 1024L*1024*1024*2 ) {
    printf("RW layer does not exist. Creating...");fflush(stdout);
    if (create_btrfs_imagefile(datafile, 128*1024*1024) == 0) {
      printf("done.\n");
    } else {
      printf("failed.\n");
    }
  }

  if (!is_file(datafile) || mount_rw_loop(datafile, "/mnt/rw") != 0) {
    printf("No valid persistent RW layer. Using tmpfs.\n");
    mount_or_die("tmpfs", "/mnt/rw", "tmpfs", MS_RELATIME, "");
  }

  if (!exists(swapfile) && get_free_disk_space("/mnt/boot") >= 1024L*1024*1024*2 ) {
    printf("Swapfile does not exist. Creating...");fflush(stdout);
    if (create_swapfile(swapfile, 1024L*1024*1024) == 0) {
      printf("done.\n");
    } else {
      printf("failed.\n");
    }
  }

  if (is_file(swapfile)) {
    printf("Activating swap...\n");
    activate_swap(swapfile);
  }

  mount_ro_loop_or_die("/mnt/boot/system.img", "/mnt/system", 0);
  mount_overlay_or_die("/mnt/system", "/mnt/rw/root", "/mnt/rw/work", NEWROOT);
  mount_or_die("tmpfs", NEWROOT"/run", "tmpfs", MS_NODEV|MS_NOSUID|MS_STRICTATIME, "mode=755");

  move_mount_or_die("/mnt/boot", NEWROOT"/run/initramfs/boot");
  move_mount_or_die("/mnt/system", NEWROOT"/run/initramfs/ro");
  move_mount_or_die("/mnt/rw", NEWROOT"/run/initramfs/rw");

  process_inifile(NEWROOT"/run/initramfs/boot/system.ini", setup);

  setup_initramfs_shutdown(NEWROOT);

  printf("Switching to newroot...\n");
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
