#include <iostream>
#include <map>
#include <cassert>

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

static bool is_file(const std::string& path)
{
  struct stat st;
  return stat(path.c_str(), &st) == 0 && S_ISREG(st.st_mode);
}

int load_disk_config(const char* vmname, std::list<Disk>& disks)
{
  VmIniFile ini(vmname);
  disks.clear();
  std::optional<std::string> disk_names = ini.getstring(":disks");
  if (!disk_names) {
    std::string img_file = (std::string)"/run/initramfs/boot/vm/" + vmname + ".img";
    std::string dat_file = (std::string)"/run/initramfs/boot/vm/" + vmname + ".dat";
    std::string swp_file = (std::string)"/run/initramfs/boot/vm/" + vmname + ".swp";
    if (!is_file(img_file)) {
      std::cerr << "No image file for VM '" << vmname << "'" << std::endl;
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
  std::list<std::string> disk_name_list;
  std::string disk_name;
  for (const char* pt = disk_names.value().c_str(); *pt; pt++) {
    if (*pt == ',') {
      disk_name_list.push_back(disk_name);
      disk_name.clear();
    } else {
      disk_name += *pt;
    }
  }
  disk_name_list.push_back(disk_name);
  for (const auto& d : disk_name_list) {
    if (!d.starts_with("xvd") || d.length() < 4 || (d[3] < 'a' || d[3] > 'z') || (d.length() == 5 && !isdigit(d[4])) || d.length() > 5) {
      std::cerr << "Invalid virtual block device name '" << d << "'. Ignored." << std::endl;
      continue;
    }
    const auto& path = ini.getstring((d + ":path").c_str());
    if (!path) {
      std::cerr << "No path defined for virtual block device '" << d << "'. Ignored." << std::endl;
      continue;
    }
    // else
    Disk disk;
    disk.name = d;
    disk.path = path.value();
    disk.readonly = ini.getboolean((d + ":readonly").c_str(), false);
    disks.push_back(disk);
  }

  return disks.size();
}

int load_nic_config(const char* vmname, std::list<NIC>& nics)
{
  VmIniFile ini(vmname);
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

int start(int argc, char* argv[])
{
  if (argc < 3) {
    std::cout << "Usage: wb start vmname" << std::endl;
    return 1;
  }
  //else
  const char* vmname = argv[2];

  std::map<std::string, VM> vms;
  list(vms);
  const auto& vm_iter = vms.find(vmname);
  if (vm_iter == vms.end()) {
    std::cerr << "No such VM. 'wb list' to show list of available VMs." << std::endl;
    return 1;
  }
  //else
  const auto& vm_config = vm_iter->second;
  if (vm_config.domid) {
    std::cerr << "Already running" << std::endl;
    return 1;
  }

  // load disks
  std::list<Disk> disks;
  load_disk_config(vm_config.name.c_str(), disks);

  // load nics
  std::list<NIC> nics;
  load_nic_config(vm_config.name.c_str(), nics);

  static int logfile = 2;
  typedef enum {
    child_console, child_waitdaemon, child_migration, child_vncviewer,
    child_max
  } xlchildnum;

  typedef struct {
      /* every struct like this must be in XLCHILD_LIST */
      pid_t pid; /* 0: not in use */
      int reaped; /* valid iff pid!=0 */
      int status; /* valid iff reaped */
      const char *description; /* valid iff pid!=0 */
  } xlchild;

  const auto INVALID_DOMID = ~0;
  XtlLoggerStdio logger(stderr, XTL_ERROR, 0);
  if (!logger) return -1;
  // else
  LibXlCtx ctx(LIBXL_VERSION, 0, logger);
  if (!ctx) return -1;

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
    /*
    int notify_pipe[2] = { -1, -1 };
    if (libxl_pipe(ctx, notify_pipe) != 0) throw std::runtime_error("libxl_pipe failed");
    //else
    libxl_asyncprogress_how autoconnect_console_how;
    autoconnect_console_how.callback = autoconnect_console;
    autoconnect_console_how.for_callback = &notify_pipe[1];
    */
    libxl_domain_create_new(ctx, d_config, &domid, 0, 0/*&autoconnect_console_how*/);
  }

  /*
  if (true) {
    char buf[1];
    int r;
    do {
      r = read(notify_pipe[0], buf, 1);
    } while (r == -1 && errno == EINTR);

    if (r == -1)
      fprintf(stderr,
            "Failed to get notification from xenconsole: %s\n",
            strerror(errno));
    else if (r == 0)
      fprintf(stderr, "Got EOF from xenconsole notification fd\n");
    else if (r == 1 && buf[0] != 0x00)
      fprintf(stderr, "Got unexpected response from xenconsole: %#x\n",
            buf[0]);

    close(notify_pipe[0]);
    close(notify_pipe[1]);
    notify_pipe[0] = notify_pipe[1] = -1;
  }
  */

  libxl_domain_unpause(ctx, domid, NULL);

  // daemonize
  static xlchild children[child_max];
  xlchild* ch = &children[child_waitdaemon];
  assert(!ch->pid);
  ch->reaped = 0;
  ch->description = "domain monitoring daemonizing child";
  ch->pid = fork();
  if (ch->pid == -1) RUNTIME_ERROR_WITH_ERRNO((std::string)"fork failed");
  //else
  if (!ch->pid) {
    for (int i = 0; i < child_max; i++) children[i].pid = 0;
  }

  if (ch->pid) {
    // xl_waitpid
    int status;
    xlchild *ch = &children[child_waitdaemon];
    pid_t got = ch->pid;
    assert(got);
    if (ch->reaped) {
      status = ch->status;
      ch->pid = 0;
    } else {
      for (;;) {
        got = waitpid(ch->pid, &status, 0);
        if (got < 0 && errno == EINTR) continue;
        if (got > 0) {
          assert(got == ch->pid);
          ch->pid = 0;
        }
        break;
      }
    }
    if (got < 0) {
      RUNTIME_ERROR_WITH_ERRNO((std::string)"failed to waitpid for " + children[child_waitdaemon].description);
    } else if (status) {
      libxl_report_child_exitstatus(ctx, XTL_ERROR, children[child_waitdaemon].description, got, status);
      RUNTIME_ERROR("child exit status is not 0");
    }
  } else {
    libxl_postfork_child_noexec(ctx); /* in case we don't exit/exec */
    char *_fullname;
    std::string name = (std::string)"xl-" + d_config.c_info.name;
    int rst = libxl_create_logfile(ctx, name.c_str(), &_fullname);
    std::string fullname = _fullname;
    free(_fullname);
    if (rst != 0) RUNTIME_ERROR_WITH_ERRNO((std::string)"failed to open logfile " + fullname);
    //else
    logfile = open(fullname.c_str(), O_WRONLY|O_CREAT|O_APPEND, 0644);
    if (logfile < 0) RUNTIME_ERROR_WITH_ERRNO((std::string)"Fatal error");
    // else
    assert(logfile >= 3);
    int nullfd = open("/dev/null", O_RDONLY);
    assert(nullfd >= 3);

    dup2(nullfd, 0);
    dup2(logfile, 1);
    dup2(logfile, 2);
    close(nullfd);
    if (daemon(0, 1) < 0) RUNTIME_ERROR_WITH_ERRNO((std::string)"Fatal error");
  }

  libxl_evgen_domain_death *deathw = NULL;
  if (libxl_evenable_domain_death(ctx, domid, 0, &deathw) != 0) goto out;
  while (true) {
    libxl_event *event;
    while (true) {
      if (libxl_event_wait(ctx, &event, LIBXL_EVENTMASK_ALL, 0,0) != 0) goto out;
      if (event->domid != domid) {
          libxl_event_free(ctx, event);
          continue;
      }
      break;
    }
    //else
    /*
    switch (event->type) {
    case LIBXL_EVENT_TYPE_DOMAIN_SHUTDOWN:
      switch (handle_domain_death(&domid, event, &d_config)) {
      case DOMAIN_RESTART_SOFT_RESET:
      case DOMAIN_RESTART_RENAME:
      case DOMAIN_RESTART_NORMAL:
      case DOMAIN_RESTART_NONE:
      default:
        abort();
      }
    case LIBXL_EVENT_TYPE_DOMAIN_DEATH:
      libxl_event_free(ctx, event);
      goto out;
    case LIBXL_EVENT_TYPE_DISK_EJECT:
      break;
    default:
      break;
    }
    */
    libxl_event_free(ctx, event);
  }

out:;
  if (logfile != 2) close(logfile);

  //if (xl_child_pid(child_console)) child_report(child_console);
  return 0;
}
