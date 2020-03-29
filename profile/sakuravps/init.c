#define INIFILE
#include "init.h"

#define PROBE_BOOT_PARTITION_MAX_RETRY 8
#define NEWROOT "/newroot"

void setup(inifile_t ini)
{
  const char *ip_address = ini_string(ini, ":ip_address", NULL);
  const char *gateway = ini_string(ini, ":gateway", NULL);
  const char *dns = ini_string(ini, ":dns", NULL);
  const char *fallback_dns = ini_string(ini, ":fallback_dns", NULL);

  const char *ipv6_address = ini_string(ini, ":ipv6_address", NULL);
  const char *ipv6_gateway = ini_string(ini, ":ipv6_gateway", NULL);
  const char *ipv6_dns = ini_string(ini, ":ipv6_dns", NULL);
  const char *ipv6_fallback_dns = ini_string(ini, ":ipv6_fallback_dns", NULL);
  const int debug = ini_bool(ini, ":debug", 0);

  setup_hostname_according_to_inifile(NEWROOT, ini);
  setup_password_according_to_inifile(NEWROOT, ini);
  set_generated_hostname_if_not_set(NEWROOT);
  setup_timezone_according_to_inifile(NEWROOT, ini);
  setup_keymap_according_to_inifile(NEWROOT, ini);

  if (ip_address || ipv6_address) {
    if (set_static_ip_address("eth0", ip_address, gateway, dns, fallback_dns, ipv6_address, ipv6_gateway, ipv6_dns, ipv6_fallback_dns) == 0) {
      if (ip_address) {
        printf("IP address set to %s\n", ip_address);
      }
      if (ipv6_address) {
        printf("IPv6 address set to %s\n", ipv6_address);
      }
    } else {
      printf("Setting static IP address failed.\n");
    }
  }

}

void init()
{
  const char* swapfile = "/mnt/boot/system.swp";
  struct partition_struct partition;
  mount_procdevsys_or_die();

  printf("Determining boot partition...");
  if (search_boot_partition(&partition, PROBE_BOOT_PARTITION_MAX_RETRY) < 0) {
    search_partition_by_fstype_or_die("vfat", &partition, PROBE_BOOT_PARTITION_MAX_RETRY);
  }
  printf("%s\n", partition.device);

  mount_or_die(partition.device, "/mnt/boot", "vfat", MS_RELATIME, "iocharset=utf8,codepage=437,fmask=177,dmask=077");
  mount_ro_loop_or_die("/mnt/boot/system.img", "/mnt/system", 0);

  if (is_file("/mnt/boot/system.cur")) {
    if (rename("/mnt/boot/system.cur", "/mnt/boot/system.old") == 0) {
      printf("Previous system image preserved.\n");
    }
  }

  printf("Mounting /dev/vda2 as RW layer...\n");
  mkdir_p("/mnt/rw");
  if (mount2("/dev/vda2", "/mnt/rw", "auto", MS_RELATIME, "") != 0) {
    printf("/dev/vda2 couldn't be mounted. Falling back to non-persistent RW layer...\n");
    mount_or_die("tmpfs", "/mnt/rw", "tmpfs", MS_RELATIME, "");
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
