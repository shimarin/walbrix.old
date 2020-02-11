#define INIFILE
#include "init.h"

#define PROBE_BOOT_PARTITION_MAX_RETRY 8
#define FIRMWARE_ARCHIVE "/newroot/run/initramfs/boot/efi/boot/firmware.tgz"

void setup(void* ini)
{
  int fd;
  const char *hostname;
  const char *password = ini_string(ini, ":password", NULL);
  const char *wifi_ssid = ini_string(ini, ":wifi_ssid", NULL);
  const char *wifi_key = ini_string(ini, ":wifi_key", "");
  const char *wg_endpoint = ini_string(ini, "wireguard:endpoint", NULL);
  const char *wg_privkey = ini_string(ini, "wireguard:private_key", "");
  const char *wg_pubkey = ini_string(ini, "wireguard:public_key", "");

  char default_hostname[10];
  uint16_t randomnumber;

  fd = open("/dev/urandom", 0);
  if (fd >= 0) {
    read(fd, &randomnumber, sizeof(randomnumber));
    close(fd);
  } else {
    strcpy(default_hostname, "localhost");
  }

  sprintf(default_hostname, "host-%04x", randomnumber);
  hostname = ini_string(ini, ":hostname", default_hostname);

  puts(hostname);

  if (wifi_ssid) {
    printf("SSID=%s, KEY=%s\n", wifi_ssid, wifi_key);
  }
  //sleep(3);
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

  if (is_file(FIRMWARE_ARCHIVE)) {
    printf("Extracting firmware...\n");
    extract_archive(FIRMWARE_ARCHIVE, "/newroot/lib/firmware", 1);
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
