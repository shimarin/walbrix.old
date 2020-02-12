#define INIFILE
#include "init.h"

#define PROBE_BOOT_PARTITION_MAX_RETRY 8
#define FIRMWARE_ARCHIVE "/run/initramfs/boot/efi/boot/firmware.tgz"

void setup(inifile_t ini)
{
  const char *hostname;
  const char *password = ini_string(ini, ":password", NULL);
  const char *timezone = ini_string(ini, ":timezone", "Asia/Tokyo");
  const char *keymap = ini_string(ini, ":keymap", "jp106");
  const char *wifi_ssid = ini_string(ini, ":wifi_ssid", NULL);
  const char *wifi_key = ini_string(ini, ":wifi_key", "");
  const int debug = ini_bool(ini, ":debug", 0);
  const char *wg_endpoint = ini_string(ini, "wireguard:endpoint", NULL);
  const char *wg_privkey = ini_string(ini, "wireguard:private_key", "");
  const char *wg_pubkey = ini_string(ini, "wireguard:public_key", "");

  char default_hostname[10];

  if (debug) {
    puts(">>>>setup");
    sleep(3);
  }

  if (generate_default_hostname(default_hostname) < 0) {
    strcpy(default_hostname, "localhost");
  }

  hostname = ini_string(ini, ":hostname", default_hostname);

  if (set_hostname("/newroot", hostname) == 0) {
    printf("hostname: %s\n", hostname);
  } else {
    printf("Hostname setup failed.\n");
    if (debug) sleep(3);
  }

  if (set_root_password("/newroot", password) == 0) {
    printf("Root password configured.\n");
  } else {
    printf("Failed to set root password.\n");
  }

  if (!password || password[0] == '\0') {
    if (enable_autologin("/newroot") == 0) {
      printf("Autologin enabled.\n");
    } else {
      printf("Autologin could not be enabled.\n");
      if (debug) sleep(3);
    }
  }

  if (set_timezone("/newroot", timezone) == 0) {
    printf("Timezone set to %s.\n", timezone);
  } else {
    printf("Timezone could not be configured.\n");
    if (debug) sleep(3);
  }

  if (set_keymap("/newroot", keymap) == 0) {
    printf("Keymap set to %s.\n", keymap);
  } else {
    printf("Keymap configuration failed.\n");
    if (debug) sleep(3);
  }

  if (wifi_ssid) {
    if (setup_wifi("/newroot", wifi_ssid, wifi_key) == 0) {
      printf("WiFi SSID: %s\n", wifi_ssid);
    } else {
      printf("WiFi setup failed.\n");
      if (debug) sleep(3);
    }
  }

  if (debug) {
    puts("<<<<setup");
    sleep(3);
  }
}

void init()
{
  struct partition_struct partition;
  mount_procdevsys_or_die();

  printf("Determining boot partition...");
  if (search_boot_partition(&partition, PROBE_BOOT_PARTITION_MAX_RETRY) < 0) {
    search_partition_by_fstype_or_die("vfat", &partition, PROBE_BOOT_PARTITION_MAX_RETRY);
  }
  printf("%s\n", partition.device);

  mount_or_die(partition.device, "/mnt/boot", "vfat", MS_RDONLY, "fmask=177,dmask=077");
  mount_or_die("tmpfs", "/mnt/rw", "tmpfs", MS_RELATIME, "");
  mount_ro_loop_or_die("/mnt/boot/efi/boot/bootx64.efi", "/mnt/system", 1048576);
  mount_overlay_or_die("/mnt/system", "/mnt/rw/root", "/mnt/rw/work", "/newroot");
  mount_or_die("tmpfs", "/newroot/run", "tmpfs", MS_NODEV|MS_NOSUID|MS_STRICTATIME, "mode=755");

  move_mount_or_die("/mnt/boot", "/newroot/run/initramfs/boot");
  move_mount_or_die("/mnt/system", "/newroot/run/initramfs/ro");
  move_mount_or_die("/mnt/rw", "/newroot/run/initramfs/rw");

  if (is_file("/newroot"FIRMWARE_ARCHIVE)) {
    printf("Extracting firmware...\n");
    extract_archive("/newroot", FIRMWARE_ARCHIVE, "/lib/firmware", 1);
  }

  setup_initramfs_shutdown("/newroot");
  process_inifile("/newroot/run/initramfs/boot/efi/boot/bootx64.ini", setup);

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
