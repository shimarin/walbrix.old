#include <iostream>

#include "initlib.h"

class MyInit : public Init {
protected:
  virtual void mount_rw(const std::filesystem::path& boot, const std::filesystem::path& mountpoint);
  virtual bool activate_swap(const std::filesystem::path& boot);
};

void MyInit::mount_rw(const std::filesystem::path& boot,
  const std::filesystem::path& mountpoint)
{
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
  MyInit init;
  init.setup();
  auto newroot = init.get_newroot();

  auto driver_for_amdgpu = init.ini_string(":driver_for_amdgpu");
  if (driver_for_amdgpu) {
    std::filesystem::path whiteout_for_amdgpu_pro[] = {
      newroot / "run/initramfs/rw/root/etc/OpenCL/vendors/amdgpu-pro-orca-amd64.icd",
      newroot / "run/initramfs/rw/root/etc/OpenCL/vendors/amdgpu-pro-pal-amd64.icd"
    };
    auto whiteout_for_rocm = newroot / "run/initramfs/rw/root/etc/OpenCL/vendors/amdocl64.icd";

    std::filesystem::create_directories(newroot / "run/initramfs/rw/root/etc/OpenCL/vendors");

    unlink(whiteout_for_amdgpu_pro[0]);
    unlink(whiteout_for_amdgpu_pro[1]);
    unlink(whiteout_for_rocm);

    if (driver_for_amdgpu.value() == "amdgpu-pro") {
      create_whiteout(whiteout_for_rocm);
    } else if (driver_for_amdgpu.value() == "rocm"){
      create_whiteout(whiteout_for_amdgpu_pro[0]);
      create_whiteout(whiteout_for_amdgpu_pro[1]);
    } else {
      std::cout << "Unknown amdgpu driver name '" << driver_for_amdgpu.value() << "' is given. ('amdgpu-pro' or 'rocm' expected)" << std::endl;
    }
  }

  return newroot;
}

void shutdown()
{
  Shutdown shutdown;
  shutdown.cleanup();
}
