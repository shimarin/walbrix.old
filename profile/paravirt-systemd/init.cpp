#include <iostream>

extern "C" {
#include <xenstore.h>
}

#include "initlib.h"

/*
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
*/

class MyInit : public Init {
protected:
  std::optional<Partition> determine_boot_partition(int max_retry = 3);
  void mount_boot(const Partition& boot_partition, const std::filesystem::path& mountpoint);
  std::optional<std::filesystem::path> get_ini_path(const std::filesystem::path& boot);
  void mount_system(const std::filesystem::path& boot, const std::filesystem::path& mountpoint);
  void mount_rw(const std::filesystem::path& boot, const std::filesystem::path& mountpoint);
  std::filesystem::path get_upperdir(const std::filesystem::path& rw_layer);
  bool activate_swap(const std::filesystem::path& boot);
  void setup_hostname(const std::filesystem::path& newroot);
public:
};

std::optional<Partition> MyInit::determine_boot_partition(int max_retry/*=3*/)
{
  return Partition { "/dev/xvda1", std::nullopt };
}

void MyInit::mount_boot(const Partition& boot_partition, const std::filesystem::path& mountpoint)
{
  if (mount(boot_partition.path, mountpoint, "auto", is_boot_partition_readonly()? MS_RDONLY : MS_RELATIME) != 0) {
    RUNTIME_ERROR("mount /mnt/boot");
  }
}

std::optional<std::filesystem::path> MyInit::get_ini_path(const std::filesystem::path& boot)
{
  return std::nullopt;
}

void MyInit::mount_system(const std::filesystem::path& boot, const std::filesystem::path& mountpoint)
{
  if (is_boot_partition_readonly()) {
    if (bind_mount(boot, mountpoint) != 0) RUNTIME_ERROR("mount --bind /mnt/boot /mnt/systdm");
  } else {
    if (mount_loop(boot / "system.img", mountpoint, "auto", MS_RDONLY) != 0) {
      if (mount_loop(boot / "system", mountpoint, "auto", MS_RDONLY) != 0) {
        RUNTIME_ERROR("mount /mnt/system");
      }
    }
  }
}

void MyInit::mount_rw(const std::filesystem::path& boot, const std::filesystem::path& mountpoint)
{
  if (is_boot_partition_readonly()) {
    if (mount("/dev/xvda2", mountpoint) != 0) {
      if (mount("tmpfs", mountpoint, "tmpfs") != 0) {
        RUNTIME_ERROR("mount /mnt/rw");
      }
    }
  } else {
    if (bind_mount(boot, mountpoint) != 0) {
      RUNTIME_ERROR("mount --bind /mnt/boot /mnt/rw");
    }
  }
}

std::filesystem::path MyInit::get_upperdir(const std::filesystem::path& rw_layer)
{
  if (is_dir(rw_layer / "rw")) { // for backward compatibility
    if (!std::filesystem::exists(rw_layer / "root")) {
      std::filesystem::create_symlink("rw", rw_layer / "root");
    }
    return rw_layer / "rw";
  }
  //else
  return Init::get_upperdir(rw_layer);
}

bool MyInit::activate_swap(const std::filesystem::path& boot)
{
  if (is_boot_partition_readonly() && is_block("/dev/xvda3")) {
    return swapon("/dev/xvda3") == 0;
  }
  //else
  return is_file(boot / "swapfile") && swapon(boot / "swapfile") == 0;
}

void MyInit::setup_hostname(const std::filesystem::path& newroot)
{
  struct xs_handle *xs;
  xs_transaction_t txn;
  unsigned int len;
  char* domname;
  bool hostname_set = false;
  xs = xs_open(XS_OPEN_READONLY);
  if (!xs) return RUNTIME_ERROR("xs_open");
  txn = xs_transaction_start(xs);
  if (txn) {
    domname = (char*)xs_read(xs, txn, "name", &len);
    if (domname) {
      char *buf = (char *)malloc(len + 1);
      if (buf) {
        memcpy(buf, domname, len);
        buf[len] = '\0';
        hostname_set = set_hostname(newroot, buf) == 0;
        free(buf);
      }
      free(domname);
    }
    xs_transaction_end(xs, txn, true);
  }
  xs_close(xs);
  if (hostname_set) return;

  //else
  if (!is_file(newroot / "run/initramfs/rw/root/etc/hostname")) {
    auto hostname = generate_default_hostname();
    if (set_hostname(newroot, hostname) == 0) {
      std::cout << "hostname(generated): " << hostname << std::endl;
    } else {
      std::cout << "Hostname setup(generated) failed." << std::endl;
    }
  }
}

std::filesystem::path init()
{
  MyInit init;
  init.setup();
  return init.get_newroot();
}

void shutdown()
{
  Shutdown shutdown;
  shutdown.cleanup();
}
