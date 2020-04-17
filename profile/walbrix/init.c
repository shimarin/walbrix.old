#include <time.h>
#define INIFILE
#include "init.h"

#define PROBE_BOOT_PARTITION_MAX_RETRY 8
#define NEWROOT "/newroot"
#define TIME_FILE "boottime.txt"

void setup(inifile_t ini)
{
  const char *default_ssh_pubkey = ini_string(ini, ":default_ssh_pubkey", NULL);

  if (default_ssh_pubkey) {
    const char *authorized_keys = NEWROOT"/root/.ssh/authorized_keys";
    if (is_nonexist_or_empty(authorized_keys)) {
      FILE *f;
      mkdir(NEWROOT"/root/.ssh", S_700);
      f = fopen(NEWROOT"/root/.ssh/authorized_keys", "w");
      if (f) {
        fprintf(f, "%s\n", default_ssh_pubkey);
        fclose(f);
      }
    } else {
      printf("SSH publickey already exists.\n");
    }
  }

  setup_hostname_according_to_inifile(NEWROOT, ini);
  set_generated_hostname_if_not_set(NEWROOT);
  setup_timezone_according_to_inifile(NEWROOT, ini);
  setup_keymap_according_to_inifile(NEWROOT, ini);
  setup_wifi_according_to_inifile(NEWROOT, ini);
}

void readonly_init(const char *boot_partition)
{
  printf("Loading Walbrix...\n");
  mount_or_die2(boot_partition, "/mnt/cdrom", "auto", MS_RDONLY, "");
  mkdir_p("/mnt/boot/efi/boot");
  if (cp_a("/mnt/cdrom/system.img", "/mnt/boot/system.img") != 0) {
    printf("Unable to copy system image to RAM.\n");
    halt();
  }
  if (is_file("/mnt/cdrom/efi/boot/bootx64.efi")) {
    cp_a("/mnt/cdrom/efi/boot/bootx64.efi", "/mnt/boot/efi/boot/bootx64.efi");
  }
  if (is_file("/mnt/cdrom/system.ini")) {
    cp_a("/mnt/cdrom/system.ini", "/mnt/boot/system.ini");
  }
  umount("/mnt/cdrom");
  mount_ro_loop_or_die("/mnt/boot/system.img", "/mnt/system", 0);
  mount_or_die("tmpfs", "/mnt/rw", "tmpfs", MS_RELATIME, "");
}

void normal_init(const char *boot_partition)
{
  const char *datafile = "/mnt/boot/system.dat";
  const char *swapfile = "/mnt/boot/system.swp";
  FILE *f;
  int rw_layer_mounted = 0;

  // mount boot partition
  mkdir_p("/mnt/boot");
  if (mount(boot_partition, "/mnt/boot", "vfat", MS_RELATIME, "fmask=177,dmask=077") < 0) {
    printf("Boot partition filesystem corrupted. Attempting repair...\n");
    repair_fat(boot_partition);
    mount_or_die(boot_partition, "/mnt/boot", "vfat", MS_RELATIME, "fmask=177,dmask=077");
  }
  mkdir_p("/mnt/boot/vm");
  mount_ro_loop_or_die("/mnt/boot/system.img", "/mnt/system", 0);

  f = fopen("/mnt/boot/"TIME_FILE, "w");
  if (f) {
    fprintf(f, "%ld\n", time(NULL));
    fclose(f);
  }

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

  btrfs_scan();
  if (is_file(datafile)) {
    rw_layer_mounted = (mount_rw_loop_btrfs(datafile, "/mnt/rw", 1/*enable compression*/) == 0);
    if (!rw_layer_mounted) {
      printf("Failed to mount RW layer. Attempting repair.\n");
      repair_btrfs_imagefile(datafile);
      rw_layer_mounted = (mount_rw_loop_btrfs(datafile, "/mnt/rw", 1/*enable compression*/) == 0);
    }
    if (!rw_layer_mounted) {
      printf("Failed to mount RW layer as BTRFS. Attempting another way.\n");
      rw_layer_mounted = (mount_rw_loop(datafile, "/mnt/rw") != 0);
    }
    if (!rw_layer_mounted) {
      printf("Mounting RW layer failed.\n");
    }
  }

  if (rw_layer_mounted) {
    printf("RW layer mounted.\n");
  } else {
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
}

void init()
{
  int fd, installer = 0;
  struct partition_struct partition;
  mount_procdevsys_or_die();

  fd = open("/proc/cmdline", O_RDONLY);
  if (fd >= 0) {
    char haystack[256], *found;
    const char *needle = "systemd.unit=installer.target";
    int r = read(fd, haystack, sizeof(haystack));
    haystack[r < sizeof(haystack)? r : 255] = '\0';
    close(fd);
    found = strstr(haystack, needle);
    if (found) {
      char c = found[strlen(needle)];
      if ((haystack == found || *(found - 1) == ' ') && (c == '\0' || c == ' ')) installer = 1;
    }
  }

  printf("Determining boot partition...");
  if (search_boot_partition(&partition, PROBE_BOOT_PARTITION_MAX_RETRY) < 0) {
    search_partition_by_fstype_or_die("vfat", &partition, PROBE_BOOT_PARTITION_MAX_RETRY);
  }
  printf("%s\n", partition.device);

  if (is_block_readonly(partition.device) || installer) { // CD-ROM, etc
    readonly_init(partition.device);
  } else {
    normal_init(partition.device);
  }

  mount_overlay_or_die("/mnt/system", "/mnt/rw/root", "/mnt/rw/work", NEWROOT);
  mount_or_die("tmpfs", NEWROOT"/run", "tmpfs", MS_NODEV|MS_NOSUID|MS_STRICTATIME, "mode=755");

  if (is_mounted("/mnt/boot")) {
    move_mount_or_die("/mnt/boot", NEWROOT"/run/initramfs/boot");
  } else {
    mkdir_p(NEWROOT"/run/initramfs");
    mv("/mnt/boot", NEWROOT"/run/initramfs/boot");
  }
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
    char boot_partition[PATH_MAX];
    int repair_boot = 0;
    printf("Unmounting filesystems...\n");
    umount_recursive("/oldroot");
    umount_recursive("/mnt/initramfs/ro");
    umount_recursive("/mnt/initramfs/rw");
    unlink("/mnt/initramfs/boot/"TIME_FILE);

    if (is_file("/mnt/initramfs/repair-boot") && get_source_device_from_mountpoint("/mnt/initramfs/boot", boot_partition) == 0) {
      repair_boot = 1;
    }
    umount_recursive("/mnt");

    if (repair_boot) {
      printf("Repairing boot partition(%s)...\n", boot_partition);
      repair_fat(boot_partition);
    }
  }
}
