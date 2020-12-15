#include <xenstore.h>

#include "init.h"

#define BOOT_PARTITION "/dev/xvda1"
#define NEWROOT "/newroot"

int set_hostname_as_domname()
{
  struct xs_handle *xs;
  xs_transaction_t txn;
  unsigned int len;
  char* domname;
  int rst = 1;
  xs = xs_open(XS_OPEN_READONLY);
  if (!xs) return 1;
  txn = xs_transaction_start(xs);
  if (txn) {
    domname = (char*)xs_read(xs, txn, "name", &len);
    if (domname) {
      char *buf = (char *)malloc(len + 1);
      if (buf) {
        memcpy(buf, domname, len);
        buf[len] = '\0';
        set_hostname(NEWROOT, buf);
        free(buf);
        rst = 0;
      }
      free(domname);
    }
    xs_transaction_end(xs, txn, true);
  }
  xs_close(xs);
  return rst;
}

void init()
{
  char *overlay = "/mnt/rw/root";
  mount_procdevsys_or_die();

  if (is_block_readonly(BOOT_PARTITION)) { // raw squashfs image
    mount_or_die2(BOOT_PARTITION, "/mnt/system", "auto", MS_RDONLY, "");
    if (is_block("/dev/xvda2")) {
      mount_or_die2("/dev/xvda2", "/mnt/rw", "auto", MS_RELATIME, "");
    } else {
      mount_or_die("tmpfs", "/mnt/rw", "tmpfs", MS_RELATIME, "");
    }
    if (is_block("/dev/xvda3")) {
      activate_swap("/dev/xvda3");
    }

  } else {
    mount_or_die2(BOOT_PARTITION, "/mnt/rw", "auto", MS_RELATIME, "");

    if (is_file("/mnt/rw/system.cur")) {
      if (rename("/mnt/rw/system.cur", "/mnt/rw/system.old") == 0) {
        printf("Previous system image preserved.\n");
      }
    }

    if (mount_ro_loop("/mnt/rw/system.img", "/mnt/system", 0) < 0) {
      mount_ro_loop_or_die("/mnt/rw/system", "/mnt/system", 0);
    }
  }
  if (is_dir("/mnt/rw/rw")) {
    overlay = "/mnt/rw/rw"; // for backward compatibility
    if (!exists("/mnt/rw/root")) symlink("rw", "/mnt/rw/root");
  }
  mount_overlay_or_die("/mnt/system", overlay, "/mnt/rw/work", NEWROOT);
  mount_or_die("tmpfs", NEWROOT"/run", "tmpfs", MS_NODEV|MS_NOSUID|MS_STRICTATIME, "mode=755");

  move_mount_or_die("/mnt/system", NEWROOT"/run/initramfs/ro");
  move_mount_or_die("/mnt/rw", NEWROOT"/run/initramfs/rw");

  set_hostname_as_domname();
  //TODO: setup eth0 according to attr/eth0/ip, attr/eth0/ipv6

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
