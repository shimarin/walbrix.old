#include <sys/mount.h>
#include <sys/utsname.h>

#include <iostream>
#include <fstream>
#include <regex>

#include "initlib.h"

class MyInit : public Init {
  bool is_installer();
protected:
  virtual void mount_boot(const Partition& boot_partition, const std::filesystem::path& mountpoint);
  virtual void mount_rw(const std::filesystem::path& boot, const std::filesystem::path& mountpoint);
  virtual bool activate_swap(const std::filesystem::path& boot);
};

bool MyInit::is_installer()
{
  if (is_boot_partition_readonly()) return true;
  //else
  std::ifstream cmdline("/proc/cmdline");
  while (!cmdline.eof()) {
    std::string arg;
    cmdline >> arg;
    if (arg == "systemd.unit=installer.target") return true;
  }
  return false;
}

void MyInit::mount_boot(const Partition& boot_partition,
  const std::filesystem::path& mountpoint)
{
  if (is_installer()) {
    std::cout << "Loading..." << std::endl;
    auto temp_ro_mount = std::filesystem::path(mountpoint).replace_filename("cdrom");
    std::filesystem::create_directory(temp_ro_mount);
    if (mount(boot_partition.path, temp_ro_mount, "auto", MS_RDONLY) != 0)
      RUNTIME_ERROR("mount /mnt/cdrom");
    if (mount("tmpfs", mountpoint, "tmpfs", MS_NODEV|MS_NOSUID|MS_STRICTATIME, "mode=755") != 0)
      RUNTIME_ERROR("mount tmpfs on /mnt/boot");
    //else
    std::filesystem::copy_file(temp_ro_mount / "system.img", mountpoint / "system.img");
    auto bootloader = temp_ro_mount / "efi/boot/bootx64.efi";
    if (is_file(bootloader)) {
      auto bootloader_dir = mountpoint / "efi/boot";
      std::filesystem::create_directories(bootloader_dir);
      std::filesystem::copy_file(bootloader, bootloader_dir / "bootx64.efi");
    }
    auto ini_file = temp_ro_mount / "system.ini";
    if (is_file(ini_file)) {
      std::filesystem::copy_file(ini_file, mountpoint / "system.ini");
    }
    auto openvpn = temp_ro_mount / "openvpn";
    if (is_dir(openvpn)) {
      cp_a(openvpn, mountpoint);
    }
    umount(temp_ro_mount);
  } else {
    if (mount(boot_partition.path, mountpoint, "vfat", MS_RELATIME, "fmask=177,dmask=077") != 0) {
      std::cout << "Boot partition filesystem corrupted. Attempting repair..." << std::endl;
      repair_fat(boot_partition.path);
      if (mount(boot_partition.path, mountpoint, "vfat", MS_RELATIME, "fmask=177,dmask=077") != 0) {
        RUNTIME_ERROR("mount boot partition");
      }
    }
    std::filesystem::create_directories(mountpoint / "vm");
  }
}

void MyInit::mount_rw(const std::filesystem::path& boot,
  const std::filesystem::path& mountpoint)
{
  if (is_installer()) {
    mount_transient_rw_layer(mountpoint);
    return;
  }
  //else

  auto datafile = boot / "system.dat";

  if (!std::filesystem::exists(datafile) && get_free_disk_space(boot) >= 1024L*1024*1024*2 ) {
    std::cout << "RW layer does not exist. Creating..." << std::flush;
    if (create_btrfs_imagefile(datafile, 128*1024*1024) == 0) {
      std::cout << "done." << std::endl;
    } else {
      std::cout << "failed." << std::endl;
    }
  }

  std::cout << "Mounting RW layer..." << std::endl;
  btrfs_scan();
  bool rw_layer_mounted = mount_loop(datafile, mountpoint, "btrfs", MS_RELATIME, "compress=zstd") == 0;
  if (!rw_layer_mounted) {
    std::cout << "Failed to mount RW layer. Attempting repair." << std::endl;
    repair_btrfs(datafile);
    rw_layer_mounted = mount_loop(datafile, mountpoint, "btrfs", MS_RELATIME, "compress=zstd") == 0;
  }
  if (!rw_layer_mounted) {
    std::cout << "No valid persistent RW layer. Falling back to tmpfs." << std::endl;
    mount_transient_rw_layer(mountpoint);
  }
}

bool MyInit::activate_swap(const std::filesystem::path& boot)
{
  if (is_installer()) return false;
  //else
  auto swapfile = boot / "system.swp";

  if (!exists(swapfile) && get_free_disk_space(boot) >= 1024L*1024*1024*2 ) {
    std::cout << "Swapfile does not exist. Creating..." << std::flush;
    if (create_swapfile(swapfile, 1024L*1024*1024) == 0) {
      std::cout << "done." << std::endl;
    } else {
      std::cout << "failed." << std::endl;
    }
  }

  if (!is_file(swapfile)) return false;
  std::cout << "Activating swap..." << std::endl;
  return (swapon(swapfile) == 0);
}

std::filesystem::path init()
{
  std::cout
    << R"( __      __        .__ ___.         .__        )" "\n"
    << R"(/  \    /  \_____  |  |\_ |_________|__|__  ___)" "\n"
    << R"(\   \/\/   /\__  \ |  | | __ \_  __ \  \  \/  /)" "\n"
    << R"( \        /  / __ \|  |_| \_\ \  | \/  |>    < )" "\n"
    << R"(  \__/\  /  (____  /____/___  /__|  |__/__/\_ \)" "\n"
    << R"(       \/        \/         \/               \/)" << std::endl;
/* TODO: remove after -
  utsname buf;
  if (uname(&buf) == 0) {
    std::cout << buf.release << std::endl;
  }
*/
  MyInit init;
  init.setup();
  auto newroot = init.get_newroot();
  std::filesystem::create_directory(newroot / "run/vm");
  bind_mount(newroot / "run/initramfs/boot/vm" , newroot / "run/vm");
  return newroot;
}

void shutdown()
{
  Shutdown shutdown;
  shutdown.cleanup();
}
