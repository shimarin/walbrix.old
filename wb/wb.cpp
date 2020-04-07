//#define STRIP_FLAG_HELP 1
#include <gflags/gflags.h>
#include <iostream>
#include <map>
#include <cstring>

#include <sys/wait.h>
#include <security/pam_appl.h>
#include <security/pam_misc.h>

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

int login(int argc, char* argv[])
{
  std::cout << "Walbrixへようこそ! 【Enterキーで操作を開始】" << std::flush;
  while (getchar() != '\n');

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

struct Command { const char* name; int (*func)(int, char**); } commands [] = {
  {"list", list},
  {"login", login},
  {"ui", ui},
  {NULL, NULL}
};

int main(int argc, char* argv[])
{
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
