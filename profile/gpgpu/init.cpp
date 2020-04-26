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

    const char* whiteout_for_amdgpu_pro[] = {
      "etc/OpenCL/vendors/amdgpu-pro-orca-amd64.icd",
      "etc/OpenCL/vendors/amdgpu-pro-pal-amd64.icd",
      NULL
    };
    const char* whiteout_for_rocm[] = {
      "etc/OpenCL/vendors/amdocl64.icd",
      "usr/lib64/libdrm.so.2",
      "usr/lib64/libdrm_amdgpu.so.1",
      "usr/lib64/libamd_comgr.so",
      NULL
    };

    auto rw_root = newroot / "run/initramfs/rw/root";

    for (int i = 0; whiteout_for_amdgpu_pro[i]; i++) {
      unlink(rw_root / whiteout_for_amdgpu_pro[i]);
    }
    for (int i = 0; whiteout_for_rocm[i]; i++) {
      unlink(rw_root / whiteout_for_rocm[i]);
    }

    if (driver_for_amdgpu.value() == "amdgpu-pro") {
      for (int i = 0; whiteout_for_rocm[i]; i++) {
        unlink(newroot / whiteout_for_rocm[i]);
      }
    } else if (driver_for_amdgpu.value() == "rocm"){
      for (int i = 0; whiteout_for_amdgpu_pro[i]; i++) {
        unlink(newroot / whiteout_for_amdgpu_pro[i]);
      }
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
