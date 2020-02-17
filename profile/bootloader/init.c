#define INIFILE
#include "init.h"

#define PROBE_BOOT_PARTITION_MAX_RETRY 8
#define FIRMWARE_ARCHIVE "/run/initramfs/boot/efi/boot/firmware.tgz"

void setup(inifile_t ini)
{
  const char *hostname = ini_string(ini, ":hostname", NULL);
  const char *password = ini_string(ini, ":password", NULL);
  const char *timezone = ini_string(ini, ":timezone", NULL);
  const char *keymap = ini_string(ini, ":keymap", NULL);
  const char *wifi_ssid = ini_string(ini, ":wifi_ssid", NULL);
  const char *wifi_key = ini_string(ini, ":wifi_key", "");
  const int persistent = ini_bool(ini, ":persistent", 0);
  const int compress = ini_bool(ini, ":compress", 1);
  const int swap = ini_bool(ini, ":swap", 0);
  const int debug = ini_bool(ini, ":debug", 0);
  const char *wg_endpoint = ini_string(ini, "wireguard:endpoint", NULL);
  const char *wg_privkey = ini_string(ini, "wireguard:private_key", "");
  const char *wg_pubkey = ini_string(ini, "wireguard:public_key", "");

  if (debug) {
    puts(">>>>setup");
    sleep(3);
  }

  if (persistent) {
    const char* datafile = "/mnt/boot/efi/boot/bootx64.dat";
    if (!exists(datafile)) {
      if (get_free_disk_space("/mnt/boot") >= 1024L*1024*1024*2 ) {
        printf("RW layer does not exist. Creating...");fflush(stdout);
        if (create_btrfs_imagefile(datafile, 1024*1024*1024) == 0) {
          printf("done.\n");
        } else {
          printf("failed.\n");
          if (debug) sleep(3);
        }
      } else {
        printf("No sufficient disk space to create RW layer.");
        if (debug) sleep(3);
      }
    }
    btrfs_scan();
    if (mount_rw_loop_btrfs(datafile, "/mnt/rw", compress) != 0) {
      printf("Failed to mount RW layer. Attempting repair.\n");
      if (debug) sleep(3);
      repair_btrfs_imagefile(datafile);
      if (mount_rw_loop_btrfs(datafile, "/mnt/rw", compress) != 0) {
        printf("No valid persistent RW layer. Using tmpfs.\n");
        if (debug) sleep(3);
      }
    }
  }

  if (!is_mounted("/mnt/rw")) {
    mount_or_die("tmpfs", "/mnt/rw", "tmpfs", MS_RELATIME, "");
  }

  mount_overlay_or_die("/mnt/system", "/mnt/rw/root", "/mnt/rw/work", "/newroot");
  mount_or_die("tmpfs", "/newroot/run", "tmpfs", MS_NODEV|MS_NOSUID|MS_STRICTATIME, "mode=755");

  move_mount_or_die("/mnt/boot", "/newroot/run/initramfs/boot");
  move_mount_or_die("/mnt/system", "/newroot/run/initramfs/ro");
  move_mount_or_die("/mnt/rw", "/newroot/run/initramfs/rw");

  if (is_file("/newroot"FIRMWARE_ARCHIVE)) {
    char hash[33];
    const char* hash_file = "/newroot/lib/firmware/.hash";
    printf("Firmware archive found. ");fflush(stdout);
    if (md5("/newroot"FIRMWARE_ARCHIVE, hash, 1) == 0) {
      char hash_prev[33] = "";
      FILE *f;
      printf("Extracting...");fflush(stdout);
      f = fopen(hash_file, "r");
      if (f) {
        if (fread(hash_prev, 32, 1, f) == 1) {
          hash_prev[32] = '\0';
        } else {
          hash_prev[0] = '\0';
        }
        fclose(f);
      }
      if (strcmp(hash, hash_prev) != 0) {
        extract_archive("/newroot", FIRMWARE_ARCHIVE, "/lib/firmware", 1);
        f = fopen(hash_file, "w");
        if (f) {
          fwrite(hash, 32, 1, f);
          fclose(f);
        }
        printf("done.\n");
      } else {
        printf("Already done.\n");
      }
    } else {
      printf("But it's broken.\n");
      if (debug) sleep(3);
    }
  }

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

  if (password) {
    if (set_root_password("/newroot", password) == 0) {
      printf("Root password configured.\n");
    } else {
      printf("Failed to set root password.\n");
    }
  }

  if (!persistent && !is_file("/newroot/run/initramfs/rw/root/etc/shadow")) {
    if (enable_autologin("/newroot") == 0) {
      printf("Autologin enabled.\n");
    } else {
      printf("Autologin could not be enabled.\n");
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

  if (swap) {
    const char* swapfile = "/newroot/run/initramfs/boot/efi/boot/bootx64.swp";
    if (!exists(swapfile)) {
      if (get_free_disk_space("/newroot/run/initramfs/boot") >= 1024L*1024*1024*2 ) {
        printf("Swapfile does not exist. Creating...");fflush(stdout);
        if (create_swapfile(swapfile, 1024L*1024*1024) == 0) {
          printf("done.\n");
        } else {
          printf("failed.\n");
          if (debug) sleep(3);
        }
      } else {
        printf("No sufficient disk space to create swapfile.");
        if (debug) sleep(3);
      }
    }

    if (is_file(swapfile)) {
      printf("Activating swap...\n");
      activate_swap(swapfile);
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

  mount_or_die(partition.device, "/mnt/boot", "vfat", MS_RELATIME, "fmask=177,dmask=077");
  mount_ro_loop_or_die("/mnt/boot/efi/boot/bootx64.efi", "/mnt/system", 1048576);

  enable_lvm();

  process_inifile("/mnt/boot/efi/boot/bootx64.ini", setup);

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
