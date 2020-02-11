#include "init.h"

#define PROBE_BOOT_PARTITION_MAX_RETRY 8

void init()
{
  struct partition_struct partition;
  mount_procdevsys_or_die();

  printf("Determining boot partition...");
  if (search_boot_partition(&partition, PROBE_BOOT_PARTITION_MAX_RETRY) < 0) {
    search_partition_by_fstype_or_die("vfat", &partition, PROBE_BOOT_PARTITION_MAX_RETRY);
  }
  printf("%s\n", partition.device);

  mount_or_die(partition.device, "/mnt/boot", "vfat", MS_RELATIME, "fmask=177,dmask=077");

  if (!exists("/mnt/boot/system.dat") && get_free_disk_space("/mnt/boot") >= 1024L*1024*1024*2 ) {
    printf("RW layer does not exist. Creating...");fflush(stdout);
    if (create_xfs_imagefile("/mnt/boot/system.dat", 1024*1024*1024) == 0) {
      printf("done.\n");
    } else {
      printf("failed.\n");
    }
  }

  if (!is_file("/mnt/boot/system.dat") || mount_rw_loop("/mnt/boot/system.dat", "/mnt/rw") != 0) {
    printf("No valid persistent RW layer. Using tmpfs.\n");
    mount_or_die("tmpfs", "/mnt/rw", "tmpfs", MS_RELATIME, "");
  }

  if (!exists("/mnt/boot/system.swp") && get_free_disk_space("/mnt/boot") >= 1024L*1024*1024*2 ) {
    printf("Swapfile does not exist. Creating...");fflush(stdout);
    if (create_swapfile("/mnt/boot/system.swp", 1024L*1024*1024) == 0) {
      printf("done.\n");
    } else {
      printf("failed.\n");
    }
  }

  if (is_file("/mnt/boot/system.swp")) {
    printf("Activating swap...\n");
    activate_swap("/mnt/boot/system.swp");
  }

  mount_ro_loop_or_die("/mnt/boot/system.img", "/mnt/system", 0);
  mount_overlay_or_die("/mnt/system", "/mnt/rw/root", "/mnt/rw/work", "/newroot");
  mount_or_die("tmpfs", "/newroot/run", "tmpfs", MS_NODEV|MS_NOSUID|MS_STRICTATIME, "mode=755");

  move_mount_or_die("/mnt/boot", "/newroot/run/initramfs/boot");
  move_mount_or_die("/mnt/system", "/newroot/run/initramfs/ro");
  move_mount_or_die("/mnt/rw", "/newroot/run/initramfs/rw");

  setup_initramfs_shutdown("/newroot");

  switch_root_or_die("/newroot");
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
