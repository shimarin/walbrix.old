#include <iostream>
#include <map>
#include <regex>
#include <cassert>

extern "C" {
#include <libxlutil.h>
}

#include "wb.h"

class LibXlDomainConfig {
  libxl_domain_config d_config;
public:
  libxl_domain_create_info& c_info;
  libxl_domain_build_info& b_info;
  int& num_disks;
  libxl_device_disk*& disks;
  int& num_nics;
  libxl_device_nic*& nics;
  libxl_action_on_shutdown& on_poweroff;
  libxl_action_on_shutdown& on_reboot;
  libxl_action_on_shutdown& on_watchdog;
  libxl_action_on_shutdown& on_crash;
  libxl_action_on_shutdown& on_soft_reset;

  LibXlDomainConfig() : c_info(d_config.c_info), b_info(d_config.b_info),
    on_poweroff(d_config.on_poweroff), on_reboot(d_config.on_reboot), on_watchdog(d_config.on_watchdog), on_crash(d_config.on_crash), on_soft_reset(d_config.on_soft_reset),
    num_disks(d_config.num_disks), disks(d_config.disks),
    num_nics(d_config.num_nics), nics(d_config.nics)
    { libxl_domain_config_init(&d_config); }
  ~LibXlDomainConfig() { libxl_domain_config_dispose(&d_config); }
  operator libxl_domain_config*() { return &d_config; }
  operator const libxl_domain_config&() { return d_config; }
};


class Lock {
  const char* lockfile = "/run/wb.lock";
  static int fd_lock;
public:
  Lock() {
    /* lock already acquired */
    if (fd_lock >= 0) RUNTIME_ERROR("Lock already acquired");

    struct flock fl;
    fl.l_type = F_WRLCK;
    fl.l_whence = SEEK_SET;
    fl.l_start = 0;
    fl.l_len = 0;
    fd_lock = open(lockfile, O_WRONLY|O_CREAT, S_IWUSR);
    if (fd_lock < 0) RUNTIME_ERROR_WITH_ERRNO((std::string)"cannot open the lockfile " + lockfile);
    if (fcntl(fd_lock, F_SETFD, FD_CLOEXEC) < 0) {
        close(fd_lock);
        RUNTIME_ERROR_WITH_ERRNO((std::string)"cannot set cloexec to lockfile " + lockfile);
    }
get_lock:
    int rc = fcntl(fd_lock, F_SETLKW, &fl);
    if (rc < 0 && errno == EINTR) goto get_lock;
    //else
    if (rc < 0) RUNTIME_ERROR_WITH_ERRNO((std::string)"cannot acquire lock " + lockfile);
  }
  ~Lock() {

    /* lock not acquired */
    if (fd_lock < 0) return;

release_lock:
    struct flock fl;
    fl.l_type = F_UNLCK;
    fl.l_whence = SEEK_SET;
    fl.l_start = 0;
    fl.l_len = 0;

    int rc = fcntl(fd_lock, F_SETLKW, &fl);
    if (rc < 0 && errno == EINTR) goto release_lock;
    //else
    //if (rc < 0) throw std::runtime_error((std::string)"cannot release lock " + lockfile + ": " + strerror(errno));
    close(fd_lock);
    fd_lock = -1;
  }
};

int Lock::fd_lock = -1;

int load_disk_config(const VmIniFile& ini, std::list<Disk>& disks)
{
  disks.clear();
  std::optional<std::string> disk_names = ini.getstring(":disks");
  if (!disk_names) {
    std::string img_file = (std::string)"/run/initramfs/boot/vm/" + ini.vmname() + ".img";
    std::string dat_file = (std::string)"/run/initramfs/boot/vm/" + ini.vmname() + ".dat";
    std::string swp_file = (std::string)"/run/initramfs/boot/vm/" + ini.vmname() + ".swp";
    if (!is_file(img_file)) {
      std::cerr << "No image file for VM '" << ini.vmname() << "'" << std::endl;
      return 0;
    }
    //else
    // setup default disks
    Disk xvda1 = Disk();
    xvda1.name = "xvda1";
    xvda1.path = img_file;
    xvda1.readonly = true; // todo: make it false in case image file contains writable filesystem
    disks.push_back(xvda1);
    if (is_file(dat_file)) {
      Disk xvda2 = Disk();
      xvda2.name = "xvda2";
      xvda2.path = dat_file;
      xvda2.readonly = false;
      disks.push_back(xvda2);
    }
    if (is_file(swp_file)) {
      Disk xvda3 = Disk();
      xvda3.name = "xvda3";
      xvda3.path = swp_file;
      xvda3.readonly = false;
      disks.push_back(xvda3);
    }
    return disks.size();
  }
  //else
  std::smatch m ;
  for (auto iter = disk_names.value().cbegin();
    std::regex_search(iter, disk_names.value().cend(), m, std::regex("[^,]+"));
    iter = m[0].second) {
    const auto& disk_name = m.str();
    if (!disk_name.starts_with("xvd") || disk_name.length() < 4 || (disk_name[3] < 'a' || disk_name[3] > 'z') || (disk_name.length() == 5 && !isdigit(disk_name[4])) || disk_name.length() > 5) {
      std::cerr << "Invalid virtual block device name '" << disk_name << "'. Ignored." << std::endl;
      continue;
    }
    const auto& path = ini.getstring((disk_name + ":path").c_str());
    if (!path) {
      std::cerr << "No path defined for virtual block device '" << disk_name << "'. Ignored." << std::endl;
      continue;
    }
    // else
    Disk disk;
    disk.name = disk_name;
    disk.path = path.value();
    disk.readonly = ini.getboolean((disk_name + ":readonly").c_str(), false);
    disks.push_back(disk);
  };

  return disks.size();
}

int load_nic_config(const VmIniFile& ini, std::list<NIC>& nics)
{
  int max_eth = 0;
  for (int i = 1; i <= 9; i++) {
    char buf[5];
    sprintf(buf, "eth%d", i);
    if (ini.exists(buf)) max_eth = i;
  }

  nics.clear();
  for (int i = 0; i <= max_eth; i++) {
    NIC nic;
    char buf[16];
    sprintf(buf, "eth%d:bridge", i);
    nic.bridge = ini.getstring(buf, "xenbr0");
    sprintf(buf, "eth%d:mac", i);
    std::optional<std::string> mac = ini.getstring(buf);
    if (mac) {
      MACAddress m(mac.value().c_str());
      if (!m) {
        std::cerr << "Invalid MAC address string " << mac.value() << ". Ignored." << std::endl;
        continue;
      }
      //else
      nic.mac = m;
    }
    nics.push_back(nic);
  }

  return nics.size();
}

struct PCI {
  std::string bdf;
  bool permissive = true;
};

int load_pci_config(const VmIniFile& ini, std::list<PCI>& pci_devices)
{
  pci_devices.clear();
  std::optional<std::string> pci_bdfs = ini.getstring(":pci");
  if (!pci_bdfs) return 0;
  //else
  std::smatch m;
  for (auto iter = pci_bdfs.value().cbegin();
    std::regex_search(iter, pci_bdfs.value().cend(), m, std::regex("[^,]+"));
    iter = m[0].second) {

    PCI pci;
    pci.bdf = m.str();
    pci_devices.push_back(pci);
  }

  return pci_devices.size();
}

uint32_t/*domid*/ start(const char* vmname)
{
  std::map<std::string, VM> vms;
  list(vms);
  const auto& vm_iter = vms.find(vmname);
  if (vm_iter == vms.end()) {
    std::cerr << "No such VM. 'wb list' to show list of available VMs." << std::endl;
    return 0;
  }
  //else
  const auto& vm_config = vm_iter->second;
  if (vm_config.domid) {
    std::cerr << "Already running" << std::endl;
    return 0;
  }

  // load disks
  VmIniFile ini(vm_config.name);
  std::list<Disk> disks;
  load_disk_config(ini, disks);

  // load nics
  std::list<NIC> nics;
  load_nic_config(ini, nics);

  std::list<PCI> pci_devices;
  load_pci_config(ini, pci_devices);

  const auto INVALID_DOMID = ~0;
  XtlLoggerStdio logger(stderr, XTL_ERROR, 0);
  if (!logger) RUNTIME_ERROR("Unable to init logger");
  // else
  LibXlCtx ctx(LIBXL_VERSION, 0, logger);
  if (!ctx) RUNTIME_ERROR("Unable to init libxl context");

  LibXlDomainConfig d_config;

  // build domain config
  d_config.c_info.name = strdup(vmname);
  d_config.c_info.type = LIBXL_DOMAIN_TYPE_PV;
  libxl_uuid_generate(&d_config.c_info.uuid);
  libxl_domain_build_info_init_type(&d_config.b_info, d_config.c_info.type);
  int memory = vm_config.mem;
  d_config.b_info.target_memkb = memory * 1024;
  d_config.b_info.max_memkb = d_config.b_info.target_memkb;
  int vcpus = vm_config.ncpu;
  if (libxl_cpu_bitmap_alloc(ctx, &d_config.b_info.avail_vcpus, vcpus) != 0) {
    RUNTIME_ERROR("Unable to allocate cpumap");
  }
  //else
  libxl_bitmap_set_none(&d_config.b_info.avail_vcpus);
  for (int i = 0; i < vcpus; i++) {
    libxl_bitmap_set((&d_config.b_info.avail_vcpus), i);
  }
  //parse_vnuma_config(config, b_info);
  d_config.b_info.max_vcpus = vcpus;

  d_config.on_poweroff = (libxl_action_on_shutdown)1/*destroy*/;
  d_config.on_reboot = (libxl_action_on_shutdown)2/*restart*/;
  d_config.on_watchdog = (libxl_action_on_shutdown)1/*destroy*/;
  d_config.on_crash = (libxl_action_on_shutdown)1/*destroy*/;
  d_config.on_soft_reset = (libxl_action_on_shutdown)7/*soft-reset*/;

  d_config.b_info.kernel = strdup(vm_config.kernel.c_str());
  d_config.num_disks = disks.size();
  d_config.disks = (libxl_device_disk*)malloc(sizeof(libxl_device_disk) * d_config.num_disks);
  int i = 0;
  for (const auto& disk_config : disks) {
    libxl_device_disk& disk = d_config.disks[i++];
    libxl_device_disk_init(&disk);
    disk.readwrite = disk_config.readonly? 0 : 1;
    disk.format = LIBXL_DISK_FORMAT_RAW;
    disk.is_cdrom = 0;
    disk.removable = 0;
    disk.vdev = strdup(disk_config.name.c_str());
    disk.pdev_path = strdup(disk_config.path.c_str());
  }
  d_config.num_nics = nics.size();
  d_config.nics = (libxl_device_nic*)malloc(sizeof(libxl_device_nic) * d_config.num_nics);
  i = 0;
  for (const auto& nic_config : nics) {
    libxl_device_nic& nic = d_config.nics[i++];
    libxl_device_nic_init(&nic);
    nic.script = strdup("vif-bridge");
    nic.nictype = LIBXL_NIC_TYPE_VIF;
    //nic.mac;
    nic.bridge = strdup(nic_config.bridge.c_str());
    if (nic_config.mac) {
      memcpy(nic.mac, nic_config.mac, sizeof(nic.mac));
    }
  }

  uint32_t domid = INVALID_DOMID;

  {
    Lock lock;
    libxl_domain_create_new(ctx, d_config, &domid, 0, 0/*&autoconnect_console_how*/);
  }

  /*
  static int pciattach(uint32_t domid, const char *bdf, const char *vs)
  {
      libxl_device_pci pcidev;
      XLU_Config *config;
      int r = 0;

      libxl_device_pci_init(&pcidev);

      config = xlu_cfg_init(stderr, "command line");
      if (!config) { perror("xlu_cfg_inig"); exit(-1); }

      if (xlu_pci_parse_bdf(config, &pcidev, bdf)) {
          fprintf(stderr, "pci-attach: malformed BDF specification \"%s\"\n", bdf);
          exit(2);
      }

      if (libxl_device_pci_add(ctx, domid, &pcidev, 0))
          r = 1;

      libxl_device_pci_dispose(&pcidev);
      xlu_cfg_destroy(config);

      return r;
  }
  */

  XLU_Config* xlu_config = xlu_cfg_init(stderr, "command line");
  if (xlu_config) {
    for (auto pci = pci_devices.cbegin(); pci != pci_devices.cend(); pci++) {
      libxl_device_pci pcidev;
      libxl_device_pci_init(&pcidev);

      if (xlu_pci_parse_bdf(xlu_config, &pcidev, (pci->permissive ? (pci->bdf + ",permissive=1") : pci->bdf).c_str()) == 0) {
        libxl_device_pci_add(ctx, domid, &pcidev, 0);
      } else {
        std::cerr << "PCI BDF " << pci->bdf << " is invalid." << std::endl;
      }
      libxl_device_pci_dispose(&pcidev);
    }
    xlu_cfg_destroy(xlu_config);
  }

  libxl_domain_unpause(ctx, domid, NULL);

  pid_t pid = fork();
  if (pid < 0) {
    std::cerr << "Warning: forking monitor process failed" << std::endl;
  } else if (pid == 0) { // child
    char domid_str[16];
    sprintf(domid_str, "%d", domid);
    execl("/proc/self/exe", "wb", "monitor", "--daemon", domid_str, NULL);
  } else { // parent
    int status;
    waitpid(pid, &status, 0);
  }

  return domid;
}

int start(int argc, char* argv[])
{
  if (argc < 3) {
    std::cout << "Usage: wb start vmname|@all" << std::endl;
    return 1;
  }
  //else
  const char* vmname = argv[2];
  if (strcmp(vmname, "@all") == 0) {
    std::map<std::string, VM> vms;
    list(vms);
    for (const auto& vm : vms) {
      if (vm.second.autostart) start(vm.first.c_str());
    }
    return 0;
  }
  //else
  uint32_t domid = start(vmname);
  return domid > 0? 0 : 1;
}
