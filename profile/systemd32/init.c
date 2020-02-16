#define INIFILE
#include "init.h"

#define PROBE_BOOT_PARTITION_MAX_RETRY 8

void setup(inifile_t ini)
{
  const char *hostname = ini_string(ini, ":hostname", NULL);
  const char *timezone = ini_string(ini, ":timezone", NULL);
  const char *keymap = ini_string(ini, ":keymap", NULL);
  const char *wifi_ssid = ini_string(ini, ":wifi_ssid", NULL);
  const char *wifi_key = ini_string(ini, ":wifi_key", "");
  const int debug = ini_bool(ini, ":debug", 0);

  if (hostname) {
    if (set_hostname("/newroot", hostname) == 0) {
      printf("hostname: %s\n", hostname);
    } else {
      printf("Hostname setup failed.\n");
      if (debug) sleep(3);
    }
  }

  if (!is_file("/newroot/run/initramfs/rw/root/etc/hostname")){
    char default_hostname[10];
    if (generate_default_hostname(default_hostname) < 0) {
      strcpy(default_hostname, "localhost");
    }
    if (set_hostname("/newroot", default_hostname) == 0) {
      printf("hostname: %s (generated)\n", default_hostname);
    } else {
      printf("Hostname setup failed.\n");
      if (debug) sleep(3);
    }
  }

  if (timezone) {
    if (set_timezone("/newroot", timezone) == 0) {
      printf("Timezone set to %s.\n", timezone);
    } else {
      printf("Timezone could not be configured.\n");
      if (debug) sleep(3);
    }
  }

  if (keymap) {
    if (set_keymap("/newroot", keymap) == 0) {
      printf("Keymap set to %s.\n", keymap);
    } else {
      printf("Keymap configuration failed.\n");
      if (debug) sleep(3);
    }
  }

  if (wifi_ssid) {
    if (setup_wifi("/newroot", wifi_ssid, wifi_key) == 0) {
      printf("WiFi SSID: %s\n", wifi_ssid);
    } else {
      printf("WiFi setup failed.\n");
      if (debug) sleep(3);
    }
  }
}

void init()
{
  const char* datafile = "/mnt/boot/systsm.dat";
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

  mount_overlay_or_die("/mnt/system", "/mnt/rw/root", "/mnt/rw/work", "/newroot");
  mount_or_die("tmpfs", "/newroot/run", "tmpfs", MS_NODEV|MS_NOSUID|MS_STRICTATIME, "mode=755");

  move_mount_or_die("/mnt/boot", "/newroot/run/initramfs/boot");
  move_mount_or_die("/mnt/system", "/newroot/run/initramfs/ro");
  move_mount_or_die("/mnt/rw", "/newroot/run/initramfs/rw");

  process_inifile("/newroot/run/initramfs/boot/system.ini", setup);

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
