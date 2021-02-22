#include <iostream>
#include <argparse/argparse.hpp>

#include "wb.h"

class LibXlEvent {
  libxl_ctx *ctx;
  libxl_event* event;
public:
  LibXlEvent(libxl_ctx* _ctx) : ctx(_ctx), event(NULL) {;}
  ~LibXlEvent() { if (event) libxl_event_free(ctx, event); }
  int wait(uint32_t domid) {
    while(true) {
      int rst = libxl_event_wait(ctx, &event, LIBXL_EVENTMASK_ALL, 0,0);
      if (rst != 0) return rst;
      if (event->domid == domid) return 0;
      //else
      libxl_event_free(ctx, event); // ignore unrelated event
      event = NULL;
      // continue
    }
  }
  int discard_all_outstanding_events() {
    int ret;
    while (!(ret = libxl_event_check(ctx, &event, LIBXL_EVENTMASK_ALL, 0,0))) {
      libxl_event_free(ctx, event);
      event = NULL;
    }
    if (ret != ERROR_NOT_READY) {
      // warning
    }
    return ret;
  }
  operator bool() { return event != NULL; }
  operator libxl_event*() { return event; }
  auto type() { return event->type; }
  auto shutdown_reason() { return event->u.domain_shutdown.shutdown_reason; }
};

static uint32_t domid = 0;
static libxl_ctx *ctx = NULL;

static void process_sigterm(int sig)
{
  if (domid == 0 || ctx == NULL) return;
  //else
  int rc = libxl_domain_shutdown(ctx, domid, NULL);
  if (rc == ERROR_DOMAIN_NOTFOUND) exit(1);
  //else
  if (rc == ERROR_NOPARAVIRT) {
    libxl_send_trigger(ctx, domid, LIBXL_TRIGGER_POWER, 0, NULL);
  }
}

int monitor(const std::vector<std::string>& args)
{
  argparse::ArgumentParser program(args[0]);
  program.add_argument("--daemon").help("Daemonize").default_value(false).implicit_value(true);
  program.add_argument("domid").help("Domain ID").action([](const std::string& value) { return std::stoi(value); });

  try {
    program.parse_args(args);
  }
  catch (const std::runtime_error& err) {
    std::cout << err.what() << std::endl;
    std::cout << program;
    return 1;
  }

  int _domid = program.get<int>("domid");
  if (_domid < 1) {
    std::cerr << "Invalid domid" << std::endl;
    return 1;
  }
  domid = (uint32_t)_domid;
  //else
  if (program.get<bool>("--daemon")) {
    daemon(0, 0);
  }

  XtlLoggerStdio logger(stderr, XTL_ERROR, 0);
  if (!logger) return -1;
  // else
  LibXlCtx ctx(LIBXL_VERSION, 0, logger);
  if (!ctx) return -1;

  //else
  ::ctx = ctx;

  char* _domname = libxl_domid_to_name(ctx, domid);
  if (!_domname) RUNTIME_ERROR("Obtaining domain name failed(already gone?)");
  std::string domname = _domname;
  free(_domname);

  libxl_evgen_domain_death* deathw = NULL;
  if (libxl_evenable_domain_death(ctx, domid, 0, &deathw) != 0) RUNTIME_ERROR("libxl_evenable_domain_death");


  //signal(SIGTERM, process_sigterm);

  while (true) {
    LibXlEvent event(ctx);
    if (event.wait(domid) != 0) RUNTIME_ERROR("libxl_event_wait");
    switch (event.type()) {
    case LIBXL_EVENT_TYPE_DOMAIN_SHUTDOWN:
      switch (event.shutdown_reason()) {
      case LIBXL_SHUTDOWN_REASON_POWEROFF:
      case LIBXL_SHUTDOWN_REASON_CRASH:
      case LIBXL_SHUTDOWN_REASON_WATCHDOG:
        libxl_evdisable_domain_death(ctx, deathw);
        libxl_domain_destroy(ctx, domid, 0);
        return 0;
      case LIBXL_SHUTDOWN_REASON_REBOOT:
      case LIBXL_SHUTDOWN_REASON_SOFT_RESET:
        libxl_evdisable_domain_death(ctx, deathw);
        libxl_domain_destroy(ctx, domid, 0);
        event.discard_all_outstanding_events();
        execl("/proc/self/exe", args[0].c_str(), "start", domname.c_str(), NULL);
        return 1;
      case LIBXL_SHUTDOWN_REASON_SUSPEND:
        continue;
      default:
        RUNTIME_ERROR("Unkonown domain death case");
      }
      break;
    case LIBXL_EVENT_TYPE_DOMAIN_DEATH:
      return 0;
    default:;
      // don't care
      break;
    }
  }
  return 0;
}

static int _main(int,char*[])
{
    return 0;
}

#ifdef __MAIN_MODULE__
int main(int argc, char* argv[]) { return _main(argc, argv); }
#endif

