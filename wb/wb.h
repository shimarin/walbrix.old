#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <fcntl.h>

#include <list>

extern "C" {
#include <iniparser.h>
}

extern "C" {
#include <libxl.h>
#include <libxl_utils.h>
}

#define RUNTIME_ERROR(msg) throw std::runtime_error((std::string)__FILE__ + '(' + std::to_string(__LINE__) + ") " + msg)
#define RUNTIME_ERROR_WITH_ERRNO(msg) throw std::runtime_error((std::string)__FILE__ + '(' + std::to_string(__LINE__) + ") " + msg + ':' + strerror(errno))

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

class MACAddress {
  uint8_t mac[6];
public:
  MACAddress() { memset(mac, 0, sizeof(mac)); }
  MACAddress(const char* mac_str) {
    memset(mac, 0, sizeof(mac));
    if (strlen(mac_str) != 17) return;
    //else
    for (int i = 0; i < 17; i++) {
      char c = tolower(mac_str[i]);
      if (i % 3 == 2) {
        if ( c != ':') return; // invalid tokenizer
        else continue;
      }
      //else
      if (!isdigit(c) && (c < 'a' || c > 'f')) return; // invalid hex char
    }
    uint8_t* ptr = mac;
    for (int i = 0; i < 17; i+=3) {
      char hb = tolower(mac_str[i]);
      char lb = tolower(mac_str[i + 1]);
      uint8_t octet = (uint8_t)((int)(hb > '9' ? hb - 'a' + 10 : hb - '0') * 16);
      octet += (uint8_t)((int)(lb > '9' ? lb - 'a' + 10 : lb - '0'));
      *ptr++ = octet;
    }
  }
  MACAddress(const MACAddress& other) { memcpy(mac, (const uint8_t*)other, sizeof(mac)); }
  operator const uint8_t*() const { return mac; }
  operator bool() const {
    for (int i = 0; i < sizeof(mac); i++) {
      if (mac[i] != 0) return true;
    }
    return false;
  }
};

typedef struct {
  std::string name;
  std::optional<uint32_t> domid = std::nullopt;
  unsigned long mem = 0;
  uint32_t ncpu = 0;
  std::string kernel;
  std::optional<std::string> ramdisk = std::nullopt;
  std::optional<std::string> cmdline = std::nullopt;
  std::optional<std::string> root = std::nullopt;
  std::optional<std::string> extra = std::nullopt;
} VM;

typedef struct {
  std::string name;
  std::string path;
  bool readonly;
} Disk;

typedef struct {
  std::string bridge;
  MACAddress mac;
} NIC;

class VmIniFile {
  dictionary* ini;
public:
  VmIniFile(const char* vmname) {
    std::string inifile = (std::string)"/run/initramfs/boot/vm/" + vmname + ".ini";
    struct stat st;
    if (stat(inifile.c_str(), &st) == 0 && S_ISREG(st.st_mode)) {
      ini = iniparser_load(inifile.c_str());
    } else {
      ini = dictionary_new(0);
    }
  }
  ~VmIniFile() { if (ini) iniparser_freedict(ini); }
  operator bool() { return ini != NULL; }
  int getint(const char* key, int default_value) { return iniparser_getint(ini, key, default_value); }
  std::optional<std::string> getstring(const char* key) {
    const char* val = iniparser_getstring(ini, key, NULL);
    return val != NULL? std::optional<std::string>(val) : std::nullopt;
  }
  std::string getstring(const char* key, const std::string& default_value) {
    char buf[default_value.length() + 1];
    strcpy(buf, default_value.c_str());
    return iniparser_getstring(ini, key, buf);
  }
  bool getboolean(const char* key, bool default_value) {
    return iniparser_getboolean(ini, key, default_value? 1: 0) == 1;
  }
  bool exists(const char* entry) { return iniparser_find_entry(ini, entry) == 1; }
};

int list(std::map<std::string,VM>& vms);
int start(int argc, char* argv[]);
