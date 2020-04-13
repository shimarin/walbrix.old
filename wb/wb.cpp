//#define STRIP_FLAG_HELP 1
#include <gflags/gflags.h>
#include <iostream>
#include <map>
#include <list>
#include <set>
#include <cstring>

#include <dirent.h>
#include <security/pam_appl.h>
#include <security/pam_misc.h>

#include <libsmartcols/libsmartcols.h>

#include <pstream.h>
#define PICOJSON_USE_INT64
#include <picojson.h>

#include <ncursesw/cursesapp.h>
#include <ncursesw/cursesp.h>
#include <ncursesw/cursesm.h>

extern "C" {
#include <xenstore.h>
}

#include "wb.h"

DEFINE_bool(daemon, false, "Daemonize");
DEFINE_bool(force, false, "Force operation");

int load_vm_config(const char* vmname, VM& vm)
{
  VmIniFile ini(vmname);

  vm.name = vmname;
  vm.autostart = ini.getboolean(":autostart", true);
  vm.mem = ini.getint(":memory", 128);
  if (vm.mem < 64) vm.mem = 64;
  vm.ncpu = ini.getint(":cpu", 1);
  if (vm.ncpu < 1) vm.ncpu = 1;
  vm.kernel = ini.getstring(":kernel", "/usr/libexec/xen/boot/pv-grub2-x86_64.gz");
  vm.ramdisk = ini.getstring(":ramdisk");
  vm.cmdline = ini.getstring(":cmdline");
  vm.root = ini.getstring(":root");
  vm.extra = ini.getstring(":extra");
  return 0;
}

int list(std::map<std::string,VM>& vms)
{
  struct dirent **namelist;
  int n = scandir("/run/initramfs/boot/vm", &namelist, NULL, alphasort);

  if (n < 0) RUNTIME_ERROR_WITH_ERRNO("scandir");
  //else
  vms.clear();
  for (int i = 0; i < n; i++) {
    if (namelist[i]->d_type == DT_REG) {
      std::string name = std::string(namelist[i]->d_name);
      std::transform(name.begin(), name.end(), name.begin(), tolower);
      if (name.ends_with(".img") || name.ends_with(".ini")) {
        name = name.substr(0, name.length() - 4);
        if (std::any_of(name.begin(), name.end(), [](char c) { return (!isalpha(c) && !isdigit(c) && c != '-'); })) {
          std::cerr << "Name '" << name << "' contains invalid character. Skipping." << std::endl;
          continue;
        }
        //else
        load_vm_config(name.c_str(), vms[name]);
      }
    }
    free(namelist[i]);
  }
  free(namelist);

  XtlLoggerStdio logger(stderr, XTL_ERROR, 0);
  if (!logger) return -1;
  // else
  LibXlCtx ctx(LIBXL_VERSION, 0, logger);
  if (!ctx) return -1;

  int nb_domain;
  libxl_dominfo* dominfo_list = libxl_list_domain(ctx, &nb_domain);
  if (!dominfo_list) RUNTIME_ERROR("Error retrieving domain list");
  //else
  for (int i = 0; i < nb_domain; i++) {
    libxl_dominfo& dominfo = dominfo_list[i];
    uint32_t domid = dominfo.domid;
    if (domid == 0) continue; // don't show dom0
    char* _domname = libxl_domid_to_name(ctx, domid);
    std::string domname = _domname;
    free(_domname);
    if (vms.find(domname) != vms.end()) {
      vms[domname].domid = domid;
      vms[domname].mem = (dominfo.current_memkb + dominfo.outstanding_memkb) / 1024;
      vms[domname].ncpu = dominfo.vcpu_online;
    }
  }
  libxl_dominfo_list_free(dominfo_list, nb_domain);
  return vms.size();
}

class Table {
  libscols_table* tb;
  libscols_line* last_line;
public:
  Table() : last_line(NULL) {
    tb = scols_new_table();
    if (!tb) RUNTIME_ERROR("Failed to allocate output table");
  }
  ~Table() { scols_unref_table(tb); }
  libscols_column* new_column(const char* colname, double hint, int flags) { return scols_table_new_column(tb, colname, hint, flags); }
  libscols_line* new_line(libscols_line* parent = NULL) {
    last_line = scols_table_new_line(tb, parent);
    if (!last_line) RUNTIME_ERROR("Failed to allocate output line");
    return last_line;
  }
  int print() { return scols_print_table(tb); }
};

class TableLine {
  libscols_line* line;
public:
  TableLine(libscols_line* _line) : line(_line) {;}
  int set_data(size_t col, const char* data) {
    char* buf = (char*)malloc(strlen(data) + 1);
    strcpy(buf, data);
    if (!buf) RUNTIME_ERROR_WITH_ERRNO("set_data");
    //else
    return scols_line_refer_data(line, col, buf);
  }
  int set_data(size_t col, const std::string& data) {
    return set_data(col, data.c_str());
  }
  template <class T> int set_data(size_t col, T data) {
    return set_data(col, std::to_string(data));
  }
};

int list(int argc, char* argv[])
{
  std::map<std::string, VM> vms;
  list(vms);
  Table table;
  table.new_column("ID", 0.1, SCOLS_FL_RIGHT);
  table.new_column("NAME", 0.1, 0);
  table.new_column("RAM(MiB)", 0.1, SCOLS_FL_RIGHT);
  table.new_column("CPUs", 0.1, SCOLS_FL_RIGHT);
  table.new_column("AUTOSTART", 0.1, SCOLS_FL_RIGHT);
  for (const auto& vm : vms) {
    TableLine line(table.new_line());
    line.set_data(0, vm.second.domid? std::to_string(vm.second.domid.value()) : "-");
    line.set_data(1, vm.first);
    line.set_data(2, vm.second.mem);
    line.set_data(3, vm.second.ncpu);
    line.set_data(4, vm.second.autostart? "yes" : "no");
  }
  table.print();

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

typedef std::tuple<std::string,std::string,uint64_t,std::string,uint16_t> PhysDisk;
const char* name(const PhysDisk& disk) { return std::get<0>(disk).c_str(); }
const char* model(const PhysDisk& disk) { return std::get<1>(disk).c_str(); }
uint64_t size(const PhysDisk& disk) { return std::get<2>(disk); }
const char* tran(const PhysDisk& disk) { return std::get<3>(disk).c_str(); }
uint16_t log_sec(const PhysDisk& disk) { return std::get<4>(disk); }

void get_install_candidates(std::list<PhysDisk>& disks,uint64_t least_size = 1024L * 1024 * 1024 * 2)
{
  redi::pstream in("lsblk -b -n -l -J -o NAME,MODEL,TYPE,PKNAME,RO,MOUNTPOINT,SIZE,TRAN,LOG-SEC");
  if (in.fail()) RUNTIME_ERROR("Failed to execute lsblk");
  // else
  picojson::value v;
  const std::string err = picojson::parse(v, in);
  if (!err.empty()) RUNTIME_ERROR(err);
  //else
  std::map<std::string,PhysDisk > disk_map;
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
  std::list<PhysDisk> disks;
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

int stop(int argc, char* argv[])
{
  if (argc < 3) {
    std::cout << "Usage: wb stop [--force] vmname" << std::endl;
    return 1;
  }
  const char* vmname = argv[2];

  std::map<std::string, VM> vms;
  list(vms);
  const auto& vm_iter = vms.find(vmname);
  if (vm_iter == vms.end()) {
    std::cerr << "No such VM. 'wb list' to show list of available VMs." << std::endl;
    return 1;
  }
  //else
  if (!vm_iter->second.domid) {
    std::cerr << "Not running" << std::endl;
    return 1;
  }

  if (FLAGS_force) {
    execl("/usr/sbin/xl", "/usr/sbin/xl", "destroy", vmname, NULL);
  } else {
    execl("/usr/sbin/xl", "/usr/sbin/xl", "shutdown", vmname, NULL);
  }
  return 0;
}

int console(int argc, char* argv[])
{
  const char* vmname = argv[2];
  execl("/usr/bin/tmux", "/usr/bin/tmux",
    "set-window-option", "-g", "status-right", " ", ";",
    "set-window-option", "-g", "window-status-current-format", "終了するには Ctrl+]を押してください", ";",
    "new", "-s", vmname, "xl", "console", vmname,
    NULL);
  return 0;
}

int setkb(int argc, char* argv[])
{
  // /etc/vconsole.conf
  // localectl set-keymap jp106
  // systemctl restart kmsconvt\@tty1
  // ] -> '['   setting is jp actially us
  // ] -> '\' setting is us actuall jp
  return 0;
}

int test_xenstore(int argc, char* argv[])
{
  auto xs = xs_open(XS_OPEN_READONLY);
  if (!xs) RUNTIME_ERROR_WITH_ERRNO("xs_open");
  xs_transaction_t txn = xs_transaction_start(xs);
  unsigned int len;
  char* content = (char*)xs_read(xs, txn, "name", &len);
  fwrite(content, 1, len, stdout);
  free(content);
  xs_transaction_end(xs, txn, true);
  xs_close(xs);
  return 0;
}

struct Command { const char* name; int (*func)(int, char**); } commands [] = {
  {"list", list},
  {"start", start},
  {"monitor", monitor},
  {"stop", stop},
  {"console", console},
  {"login", login},
  {"setkb", setkb},
  {"ui", ui},
  {"install", install},
  {"test_xenstore", test_xenstore},
  {NULL, NULL}
};

int main(int argc, char* argv[])
{
  setlocale( LC_ALL, "ja_JP.utf8"); // TODO: read /etc/locale.conf

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
