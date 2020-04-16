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

extern "C" {
#include <xenstore.h>
}

#include "wb.h"

DEFINE_bool(daemon, false, "Daemonize");
DEFINE_bool(force, false, "Force operation");

int fork_exec_wait(const char* cmd, const std::vector<std::string>& args)
{
  char* argv[args.size() + 1];
  for (int i = 0; i < args.size(); i++) {
    argv[i] = (char*)/*argggh*/args[i].c_str();
  }
  argv[args.size()] = NULL;
  pid_t pid = fork();
  if (pid < 0) RUNTIME_ERROR_WITH_ERRNO("fork");
  //else
  int rst;
  if (pid == 0) { //child
    if (execv(cmd, argv) < 0) _exit(-1);
  } else { // parent
    waitpid(pid, &rst, 0);
  }
  return WIFEXITED(rst)? WEXITSTATUS(rst) : -1;
}

int fork_exec_wait(const char* cmd, ...)
{
  std::vector<std::string> args;

  va_list list;
  va_start(list, cmd);
  char* arg;
  while ((arg = va_arg(list, char *)) != NULL) {
    args.push_back(arg);
  }
  va_end(list);
  return fork_exec_wait(cmd, args);
}

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

int ui(int argc, char* argv[])
{
  return ui(false);
}

int login(int argc, char* argv[])
{
  {
    Termbox termbox;
    TbRootWindow root = termbox.root();
    const char* msg = "    Walbrixへようこそ！\n 【Enterキーで操作を開始】";
    auto size = measure_text_size(msg);
    TbWindow win(size.first, size.second);

    win.draw_text(0, 0, msg);
    win.draw_center(root);
    tb_present();
    tb_event event;
    while (true) {
      tb_poll_event(&event);
      if (event.key == TB_KEY_ENTER) break;
    }
  }

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

int license(int argc, char* argv[]) {
  std::cout << "Open Source License" << std::endl;
  std::cout << "[termbox https://github.com/nsf/termbox]" << std::endl;
  std::cout << "Copyright (C) 2010-2013 nsf <no.smile.face@gmail.com>\n\
\n\
Permission is hereby granted, free of charge, to any person obtaining a copy\n\
of this software and associated documentation files (the \"Software\"), to deal\n\
in the Software without restriction, including without limitation the rights\n\
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\n\
copies of the Software, and to permit persons to whom the Software is\n\
furnished to do so, subject to the following conditions:\n\
\n\
The above copyright notice and this permission notice shall be included in\n\
all copies or substantial portions of the Software.\n\
\n\
THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n\
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n\
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n\
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n\
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\n\
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN\n\
THE SOFTWARE." << std::endl;
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
  {"license", license},
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
      try {
        return p->func(argc, argv);
      }
      catch (const std::exception& e) {
        std::cerr << "Excepion: " << e.what() << std::endl;
        return 1;
      }
    }
  }

  std::cerr << "No such subcommand as '" << subcommand << "'" << std::endl;
  return 1;
}
