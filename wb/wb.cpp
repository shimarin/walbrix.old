//#define STRIP_FLAG_HELP 1
#include <gflags/gflags.h>
#include <iostream>
#include <map>
#include <list>
#include <cstring>

#include <sys/wait.h>
#include <security/pam_appl.h>
#include <security/pam_misc.h>

#include <pstream.h>
#define PICOJSON_USE_INT64
#include <picojson.h>

#include <ncursesw/cursesapp.h>
#include <ncursesw/cursesp.h>
#include <ncursesw/cursesm.h>

extern "C" {
#include <libxl.h>
#include <libxl_utils.h>
}

DEFINE_bool(yesno, false, "なんかyesno");

class XtlLoggerStdio {
  xentoollog_logger_stdiostream* logger;
public:
  XtlLoggerStdio(FILE* f, xentoollog_level min_level, unsigned flags)
  {
    logger = xtl_createlogger_stdiostream(f, min_level, flags);
  }
  operator xentoollog_logger*() { return (xentoollog_logger*)logger; }
  operator bool() { return logger != NULL; }
  ~XtlLoggerStdio()
  {
    if (logger) xtl_logger_destroy((xentoollog_logger*)logger);
  }
};

class LibXlCtx {
  libxl_ctx* pctx;
public:
  LibXlCtx(int version, unsigned int flags, xentoollog_logger *lg)
  {
    int rst = libxl_ctx_alloc(&pctx, LIBXL_VERSION, 0, lg);
    if (rst != 0) pctx = NULL;
  }
  operator libxl_ctx*() { return pctx; }
  operator bool() { return pctx != NULL; }
  ~LibXlCtx()
  {
    if (pctx) libxl_ctx_free(pctx);
  }
};

int list(int argc, char* argv[])
{
  XtlLoggerStdio logger(stderr, XTL_ERROR, 0);
  if (!logger) return -1;
  // else
  LibXlCtx ctx(LIBXL_VERSION, 0, logger);
  if (!ctx) return -1;

  int nb_domain;
  libxl_dominfo* dominfo_list = libxl_list_domain(ctx, &nb_domain);
  if (dominfo_list) {
    for (int i = 0; i < nb_domain; i++) {
      libxl_dominfo& dominfo = dominfo_list[i];
      uint32_t domid = dominfo.domid;
      unsigned long mem = (dominfo.current_memkb + dominfo.outstanding_memkb) / 1024;
      uint32_t ncpu = dominfo.vcpu_online;
      char* _domname = libxl_domid_to_name(ctx, domid);
      std::string domname = _domname;
      free(_domname);
      std::cout << domid << ":" << domname << ":" << mem << ":" << ncpu << std:: endl;
    }
    libxl_dominfo_list_free(dominfo_list, nb_domain);
  } else {
    return -1;
  }
  return 0;
}

int ui(bool login = false)
{
  while (true) {
    std::cout << "1) シャットダウン" << std::endl;
    std::cout << "2) 再起動" << std::endl;
    if (login) {
      std::cout << "3) Linuxコンソール" << std::endl;
    }
    std::cout << "0) メニューを終了" << std::endl;
    std::cout << "> ";
    unsigned short n;
    std::cin >> n;
    switch (n) {
    case 0:
      return 0;
    case 1:
      execl("/sbin/poweroff", "/sbin/poweroff", NULL);
      break;
    case 2:
      execl("/sbin/reboot", "/sbin/reboot", NULL);
      break;
    case 3:
      if (login) return 9;
    default:
      break;
    }
  }
}

int ui(int argc, char* argv[])
{
  return ui(false);
}


class Login : public NCursesApplication {
public:
  Login() : NCursesApplication(TRUE) {;}
  virtual int run()
  {
    NCursesWindow border(4, 30, 10, 10);
    NCursesWindow panel(border);
    panel.printw(0, 0, "    Walbrixへようこそ！\n 【Enterキーで操作を開始】");
    border.refresh();
    while (panel.getch() != '\n');
    return 0;
  }
};

int login(int argc, char* argv[])
{
  Login loginApp;
  loginApp();
  endwin();

  pam_handle_t *pamh;
  struct pam_conv conv = { misc_conv, NULL };
  pam_start("login", "root", &conv, &pamh);
  int rc;
  do {
    rc = pam_authenticate(pamh, 0);
  } while (rc != PAM_SUCCESS && rc != PAM_ABORT && rc != PAM_MAXTRIES);
  pam_end(pamh, rc);

  if (rc == PAM_ABORT || rc == PAM_MAXTRIES) return -1;

  if (ui(true) == 9) {
    std::cout << "コンソールを抜けるには exit と入力してください。" << std::endl;
    execl("/bin/login", "/bin/login", "-p", "-f", "root", NULL);
  }
  //else
  return 0;
}

typedef std::tuple<std::string,std::string,uint64_t,std::string,uint16_t> Disk;
const char* name(const Disk& disk) { return std::get<0>(disk).c_str(); }
const char* model(const Disk& disk) { return std::get<1>(disk).c_str(); }
uint64_t size(const Disk& disk) { return std::get<2>(disk); }
const char* tran(const Disk& disk) { return std::get<3>(disk).c_str(); }
uint16_t log_sec(const Disk& disk) { return std::get<4>(disk); }

void get_install_candidates(std::list<Disk>& disks,uint64_t least_size = 1024L * 1024 * 1024 * 2)
{
  redi::pstream in("lsblk -b -n -l -J -o NAME,MODEL,TYPE,PKNAME,RO,MOUNTPOINT,SIZE,TRAN,LOG-SEC");
  if (in.fail()) throw std::runtime_error("Failed to execute lsblk");
  // else
  picojson::value v;
  const std::string err = picojson::parse(v, in);
  if (!err.empty()) throw std::runtime_error(err);
  //else
  std::map<std::string,Disk > disk_map;
  for (auto& _d : v.get<picojson::object>()["blockdevices"].get<picojson::array>()) {
    picojson::object& d = _d.get<picojson::object>();
    if (d["pkname"].is<picojson::null>() && d["type"].get<std::string>() == "disk" && d["ro"].get<bool>() == false && d["mountpoint"].is<picojson::null>()) {
      const std::string& name = d["name"].get<std::string>();
      const auto& model = d["model"];
      const auto& tran = d["tran"];
      uint64_t size = d["size"].get<int64_t>();
      if (size >= least_size) {
        disk_map[name] = std::make_tuple(
          (std::string)"/dev/" + name,
          model.is<std::string>()? model.get<std::string>() : "-",
          size,
          tran.is<std::string>()? tran.get<std::string>() : "?",
          d["log-sec"].get<int64_t>());
      }
    } else {
      if (d["pkname"].is<std::string>()) {
        const std::string pkname = d["pkname"].get<std::string>();
        if (disk_map.find(pkname) != disk_map.end() && d["mountpoint"].is<std::string>()) disk_map.erase(pkname);
      }
    }
  }

  disks.clear();
  for (const auto& entry : disk_map) {
    disks.push_back(entry.second);
  }

}

std::string size_to_human_string(uint64_t bytes)
{
	char buf[32];
	const char *letters = "BKMGTPE";
  std::string suffix;

  int exp;
  for (exp = 10; exp <= 60; exp += 10) {
    if (bytes < (1ULL << exp)) break;
  }
  exp -= 10;

	char c = *(letters + (exp ? exp / 10 : 0));
	int dec  = exp ? bytes / (1ULL << exp) : bytes;
	uint64_t frac = exp ? bytes % (1ULL << exp) : 0;

  suffix += c;
	if ((c != 'B')) suffix += "iB";

	if (frac) {
		frac = (frac / (1ULL << (exp - 10)) + 50) / 100;
		if (frac == 10) dec++, frac = 0;
		snprintf(buf, sizeof(buf), "%d.%" PRIu64 "%s", dec, frac, suffix.c_str());
	} else {
		snprintf(buf, sizeof(buf), "%d%s", dec, suffix.c_str());
  }
	return buf;
}

class Installer : public NCursesApplication {
public:
  Installer() : NCursesApplication(TRUE) {;}
  virtual int run()
  {
    //NCursesWindow border(4, 30, 10, 10);
    NCursesMenuItem item1("あれ", "あれです");
    NCursesMenuItem item2("それ", "それです");
    NCursesMenuItem item3("おわり", "おわりです");
    NCursesMenuItem term;
    NCursesMenuItem* items[] = {&item1, &item2, &item3, NULL};
    NCursesMenu menu(items, 3, 30, 0, 0, TRUE);
    menu.post();
    //border.printw(0, 1, " Walbrixインストーラー ");

    //panel.printw(0, 0, " 【Enterキーで操作を開始】");
    menu.refresh();
    while (menu.getch() != '\n');
    return 0;
  }
};

int install(int argc, char* argv[])
{
  std::list<Disk> disks;
  try {
    get_install_candidates(disks);
    for (const auto& disk : disks) {
      std::cout << name(disk) << ":" << model(disk) << ":" << size_to_human_string(size(disk)) << ":" << tran(disk) << ":" << log_sec(disk) << std::endl;
    }
  }
  catch (const std::exception& e) {
    std::cerr << e.what() << std::endl;
    return 1;
  }

  Installer installer;
  installer();
  endwin();

  return 0;
}

class LibXlDomainConfig {
  libxl_domain_config d_config;
public:
  libxl_domain_create_info& c_info;
  libxl_domain_build_info& b_info;
  int& num_disks;
  libxl_device_disk*& disks;
  int& num_nics;
  libxl_device_nic*& nics;

  LibXlDomainConfig() : c_info(d_config.c_info), b_info(d_config.b_info),
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
    if (fd_lock >= 0) throw std::runtime_error("Lock already acquired");

    struct flock fl;
    fl.l_type = F_WRLCK;
    fl.l_whence = SEEK_SET;
    fl.l_start = 0;
    fl.l_len = 0;
    fd_lock = open(lockfile, O_WRONLY|O_CREAT, S_IWUSR);
    if (fd_lock < 0) {
      throw std::runtime_error((std::string)"cannot open the lockfile " + lockfile + ": " + strerror(errno));
    }
    if (fcntl(fd_lock, F_SETFD, FD_CLOEXEC) < 0) {
        close(fd_lock);
        throw std::runtime_error((std::string)"cannot set cloexec to lockfile " + lockfile + ": " + strerror(errno));
    }
get_lock:
    int rc = fcntl(fd_lock, F_SETLKW, &fl);
    if (rc < 0 && errno == EINTR) goto get_lock;
    //else
    if (rc < 0) throw std::runtime_error((std::string)"cannot acquire lock " + lockfile + ": " + strerror(errno));
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

int start(int argc, char* argv[])
{
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
  d_config.c_info.name = strdup("mydomain");
  d_config.c_info.type = LIBXL_DOMAIN_TYPE_PV;
  libxl_uuid_generate(&d_config.c_info.uuid);
  libxl_domain_build_info_init_type(&d_config.b_info, d_config.c_info.type);
  int memory = 1024;
  d_config.b_info.target_memkb = memory * 1024;
  d_config.b_info.max_memkb = d_config.b_info.target_memkb;
  int vcpus = 1;
  if (libxl_cpu_bitmap_alloc(ctx, &d_config.b_info.avail_vcpus, vcpus) != 0) {
    throw std::runtime_error("Unable to allocate cpumap");
  }
  //else
  libxl_bitmap_set_none(&d_config.b_info.avail_vcpus);
  for (int i = vcpus; vcpus > 0; vcpus--) {
    libxl_bitmap_set((&d_config.b_info.avail_vcpus), i);
  }
  d_config.b_info.max_vcpus = vcpus;
  d_config.b_info.kernel = strdup("/usr/libexec/xen/boot/pv-grub2-x86_64.gz");
  d_config.num_disks = 1;
  d_config.disks = (libxl_device_disk*)malloc(sizeof(libxl_device_disk) * d_config.num_disks);
  for (int i = 0 ; i < d_config.num_disks; i++) {
    libxl_device_disk& disk = d_config.disks[i];
    libxl_device_disk_init(&disk);
    disk.readwrite = 1;
    disk.format = LIBXL_DISK_FORMAT_RAW;
    disk.is_cdrom = 0;
    disk.removable = 0;
    disk.vdev = strdup("xvda1");
    //disk.script = strdup("file");
    disk.pdev_path = strdup("/root/walbrix.squashfs");
  }
  d_config.num_nics = 1;
  d_config.nics = (libxl_device_nic*)malloc(sizeof(libxl_device_nic) * d_config.num_nics);
  for (int i = 0 ; i < d_config.num_nics; i++) {
    libxl_device_nic& nic = d_config.nics[i];
    libxl_device_nic_init(&nic);
    nic.nictype = LIBXL_NIC_TYPE_VIF;
    //nic.mac;
    nic.bridge = strdup("xenbr0");
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
  if (ch->pid == -1) {
    throw std::runtime_error((std::string)"fork failed: " + strerror(errno));
  }
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
      throw std::runtime_error((std::string)"failed to waitpid for " + children[child_waitdaemon].description + ": " + strerror(errno));
    } else if (status) {
      libxl_report_child_exitstatus(ctx, XTL_ERROR, children[child_waitdaemon].description, got, status);
      throw std::runtime_error("child exit status is not 0");
    }
  } else {
    libxl_postfork_child_noexec(ctx); /* in case we don't exit/exec */
    char *_fullname;
    std::string name = (std::string)"xl-" + d_config.c_info.name;
    int rst = libxl_create_logfile(ctx, name.c_str(), &_fullname);
    std::string fullname = _fullname;
    free(_fullname);
    if (rst != 0) {
      throw std::runtime_error((std::string)"failed to open logfile " + fullname + ": " + strerror(errno));
    }
    //else
    logfile = open(fullname.c_str(), O_WRONLY|O_CREAT|O_APPEND, 0644);
    if (logfile < 0) {
      throw std::runtime_error((std::string)"Fatal error: " + strerror(errno));
    }
    // else
    assert(logfile >= 3);
    int nullfd = open("/dev/null", O_RDONLY);
    assert(nullfd >= 3);

    dup2(nullfd, 0);
    dup2(logfile, 1);
    dup2(logfile, 2);
    close(nullfd);
    if (daemon(0, 1) < 0) {
      throw std::runtime_error((std::string)"Fatal error: " + strerror(errno));
    }
  }
  if (logfile != 2) close(logfile);
  //if (xl_child_pid(child_console)) child_report(child_console);
  return 0;
}

struct Command { const char* name; int (*func)(int, char**); } commands [] = {
  {"list", list},
  {"start", start},
  {"login", login},
  {"ui", ui},
  {"install", install},
  {NULL, NULL}
};

int main(int argc, char* argv[])
{
  setlocale( LC_ALL, "ja_JP.utf8");

  gflags::SetUsageMessage("Walbrix command line tool");
  gflags::SetVersionString("0.1");
  gflags::ParseCommandLineFlags(&argc, &argv, true);

  if (argc < 2) {
    std::cerr << "Subcommand must be specified. Available subcommands are:" << std::endl;
    for (Command* p = commands; p->name; p++) {
      std::cerr << p->name << std::endl;
    }
    return 1;
  }

  const char* subcommand = argv[1];

  for (Command* p = commands; p->name; p++) {
    if (strcmp(subcommand, p->name) == 0) {
      return p->func(argc, argv);
    }
  }

  std::cerr << "No such subcommand as '" << subcommand << "'" << std::endl;
  return 1;
}
