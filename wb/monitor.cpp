#include <iostream>
#include <gflags/gflags.h>

#include "wb.h"

DECLARE_bool(daemon);

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

int monitor(int argc, char* argv[])
{
  if (argc < 3) {
    std::cout << "Usage: wb monitor [--daemon] domid" << std::endl;
    return 1;
  }
  //else
  int _domid = atoi(argv[2]);
  if (_domid < 1) {
    std::cerr << "Invalid domid" << std::endl;
    return 1;
  }
  uint32_t domid = (uint32_t)_domid;
  //else
  if (FLAGS_daemon) {
    daemon(0, 0);
  }

  XtlLoggerStdio logger(stderr, XTL_ERROR, 0);
  if (!logger) return -1;
  // else
  LibXlCtx ctx(LIBXL_VERSION, 0, logger);
  if (!ctx) return -1;

  char* _domname = libxl_domid_to_name(ctx, domid);
  if (!_domname) RUNTIME_ERROR("Obtaining domain name failed(already gone?)");
  std::string domname = _domname;
  free(_domname);

  libxl_evgen_domain_death* deathw = NULL;
  if (libxl_evenable_domain_death(ctx, domid, 0, &deathw) != 0) RUNTIME_ERROR("libxl_evenable_domain_death");

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
        execl("/proc/self/exe", argv[0], "start", domname.c_str(), NULL);
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
