#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <fcntl.h>

#include <list>
#include <map>
#include <vector>
#include <optional>
#include <functional>
#include <algorithm>
#include <sstream>
#include <filesystem>

#include <libsmartcols/libsmartcols.h>

extern "C" {
#include <iniparser.h>
}

extern "C" {
#include <libxl.h>
#include <libxl_utils.h>
}

#include "termbox.h"

#define RUNTIME_ERROR(msg) throw std::runtime_error((std::string)__FILE__ + '(' + std::to_string(__LINE__) + ") " + msg)
#define RUNTIME_ERROR_WITH_ERRNO(msg) throw std::runtime_error((std::string)__FILE__ + '(' + std::to_string(__LINE__) + ") " + msg + ':' + strerror(errno))

static const std::filesystem::path vm_root("/var/vm");

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
  bool autostart;
  std::optional<uint32_t> domid = std::nullopt;
  unsigned long mem = 0;
  uint32_t ncpu = 0;
  bool pvh = false;
  std::string kernel;
  std::optional<std::string> ramdisk = std::nullopt;
  std::optional<std::string> cmdline = std::nullopt;
  //std::optional<std::string> root = std::nullopt;
  //std::optional<std::string> extra = std::nullopt;
} VM;

typedef struct {
  std::string name;
  std::string path;
  bool readonly;
} Disk;

typedef struct {
  std::string tag;
  std::string path;
} P9;

typedef struct {
  std::string bridge;
  MACAddress mac;
} NIC;

class VmIniFile {
  dictionary* ini;
  std::string _vmname;
public:
  VmIniFile(const std::string& __vmname) : _vmname(__vmname) {
    auto inifile = vm_root / __vmname / "vm.ini";
    struct stat st;
    if (stat(inifile.c_str(), &st) == 0 && S_ISREG(st.st_mode)) {
      ini = iniparser_load(inifile.c_str());
    } else {
      ini = dictionary_new(0);
    }
  }
  ~VmIniFile() { if (ini) iniparser_freedict(ini); }
  const std::string& vmname() const { return _vmname; }
  operator bool() const { return ini != NULL; }
  int getint(const char* key, int default_value) const { return iniparser_getint(ini, key, default_value); }
  std::optional<std::string> getstring(const char* key) const {
    const char* val = iniparser_getstring(ini, key, NULL);
    return val != NULL? std::optional<std::string>(val) : std::nullopt;
  }
  std::string getstring(const char* key, const std::string& default_value) const {
    char buf[default_value.length() + 1];
    strcpy(buf, default_value.c_str());
    return iniparser_getstring(ini, key, buf);
  }
  bool getboolean(const char* key, bool default_value) const {
    return iniparser_getboolean(ini, key, default_value? 1: 0) == 1;
  }
  bool exists(const char* entry) const { return iniparser_find_entry(ini, entry) == 1; }
};

std::pair<uint16_t, uint16_t> measure_text_size(const char* text);
std::pair<uint16_t, uint16_t> resize(const std::pair<uint16_t, uint16_t>& size, int16_t width, int16_t height);

class TbAbstractWindow {
  uint16_t _width, _height;
  std::optional<std::string> _caption;
public:
  TbAbstractWindow(uint16_t __width, uint16_t __height, std::optional<std::string> __caption = std::nullopt) : _width(__width), _height(__height), _caption(__caption) {;}
  virtual ~TbAbstractWindow() {;}
  virtual operator tb_cell*() = 0;

  tb_cell& cell_at(uint16_t x, uint16_t y) { return ((tb_cell*)(*this))[y * _width + x]; }

  uint16_t width() { return _width; }
  uint16_t height() { return _height; }

  void put_cell(int16_t x, int16_t y, const tb_cell& cell) {
    tb_put_cell(x, y, &cell);
  }
  void change_cell(int16_t x, int16_t y, uint32_t ch, uint16_t fg = TB_DEFAULT, uint16_t bg = TB_DEFAULT) {
    if (x < 0 || x >= _width || y < 0 || y >= _height) return;
    //else
    tb_cell& cell = cell_at(x, y);
    cell.ch = ch;
    cell.fg = fg;
    cell.bg = bg;
  }

  void draw_text(int16_t x, int16_t y, const char* text, uint16_t fg = TB_DEFAULT, uint16_t bg = TB_DEFAULT);
  void draw_text_center(int16_t y, const char* text, uint16_t fg = TB_DEFAULT, uint16_t bg = TB_DEFAULT);
  void draw_hline(int16_t y) {
    if (y < 0 || y >= _height) return;
    //else
    for (uint16_t x = 0 ; x < _width; x++) {
     // ─
      change_cell(x, y, 0x2500);
    }
  }

  virtual void draw_self() {;} // to be overridden

  void draw(TbAbstractWindow& dst, int16_t x, int16_t y, bool border = true);

  void draw_center(TbAbstractWindow& dst, bool border = true) {
    int16_t x = dst.width() / 2 - (_width + (border? 2 : 0)) / 2;
    int16_t y = dst.height() / 2 - (_height + (border? 2 : 0)) / 2;
    draw(dst, x, y, border);
  }

};

class TbRootWindow : public TbAbstractWindow {
  friend class Termbox;
  TbRootWindow() : TbAbstractWindow(tb_width(), tb_height()) {;}
public:
  virtual operator tb_cell*() { return tb_cell_buffer(); }
};

class Termbox {
public:
  Termbox() { if (tb_init() != 0) RUNTIME_ERROR("tb_init"); }
  ~Termbox() { tb_shutdown(); }
  void clear() { tb_clear(); }
  void present() { tb_present(); }
  int peek_event(tb_event* event, int timeout) {
    auto event_type = tb_peek_event(event, timeout);
    if (event_type < 0) RUNTIME_ERROR("tb_peek_event");
    return event_type;
  }
  int poll_event(tb_event* event) {
    auto event_type = tb_poll_event(event);
    if (event_type < 0) RUNTIME_ERROR("tb_poll_event");
    return event_type;
  }
  bool wait_for_enter_or_esc_key() {
    tb_event event;
    while (true) {
      if (poll_event(&event) != TB_EVENT_KEY) continue;
      if (event.key == TB_KEY_ENTER) return true;
      if (event.key == TB_KEY_ESC) return false;
    }
  }
  TbRootWindow root() { return TbRootWindow(); }
};

class TbWindow : public TbAbstractWindow {
  tb_cell* _buffer;
public:
  TbWindow(uint16_t width, uint16_t height, std::optional<std::string> caption = std::nullopt) : TbAbstractWindow(width, height, caption) {
    if (width < 1 || height < 1) RUNTIME_ERROR("Invalid window size");
    _buffer = (tb_cell*)malloc(sizeof(tb_cell) * width * height);
    if (!_buffer) RUNTIME_ERROR("Failed to allocate window drawing buffer");
    memset(_buffer, 0, width * height * sizeof(tb_cell));
  }
  TbWindow(std::pair<uint16_t, uint16_t> size, std::optional<std::string> caption = std::nullopt) : TbWindow(size.first, size.second, caption) {;}
  virtual ~TbWindow() {
    if (_buffer) free(_buffer);
  }
  operator tb_cell*() { return _buffer; }
};

template <typename T> class TbMenu {
  int16_t _selection;
  std::list<std::tuple<std::optional<T>,std::string,bool> > items;
  uint16_t _width;
public:
  TbMenu() : _selection(-1), _width(0) {}
  void add_item(std::optional<T> value, const char* label, bool center = false) {
    items.push_back(std::make_tuple(value, label, center));
    auto label_width = measure_text_size(label).first;
    if (label_width > _width) _width = label_width;
  }
  std::pair<uint16_t, uint16_t> get_size() {
    uint16_t width = 0, height = 0;
    for (const auto& i : items) {
      auto size = measure_text_size(std::get<1>(i).c_str());
      width = size.first > width? size.first : width;
      height += size.second;
    }
    return std::make_pair(width, height);
  }
  std::optional<T> get_selected()
  {
    if (_selection >= 0) {
      auto ii = items.cbegin();
      for (int i = 0; ii != items.cend(); i++, ii++) {
        if (i == _selection) {
          return std::get<0>(*ii);
        }
      }
    }
    return std::nullopt;
  }
  void selection(int16_t __selection) { _selection = __selection; }
  int16_t selection() { return _selection; }
  uint16_t width() { return _width; }
  std::pair<bool, std::optional<T> > process_event(tb_event& event) {
    if (event.type == TB_EVENT_KEY) {
      switch(event.key) {
      case TB_KEY_ARROW_UP:
        if (_selection < 0) _selection = items.size() - 1;
        else if (_selection > 0) _selection--;
        return std::make_pair(false, get_selected());
      case TB_KEY_ARROW_DOWN:
        if (_selection < 0) _selection = 0;
        else if (_selection < items.size() - 1) _selection++;
        return std::make_pair(false, get_selected());
      case TB_KEY_ENTER: return std::make_pair(true, get_selected());
      case TB_KEY_ESC: return std::make_pair(true, std::nullopt);
      default: break;
      }
    }
    //else
    return std::make_pair(false, get_selected());
  }
  void draw(TbWindow& window, int16_t x = 0, int16_t y = 0) {
    auto ii = items.cbegin();
    for (int i = 0; ii != items.cend(); i++, ii++) {
      if (std::get<2>(*ii)) {
        window.draw_text_center(y + i, std::get<1>(*ii).c_str());
      } else {
        window.draw_text(x, y + i, std::get<1>(*ii).c_str());
      }
      for (int xi = 0; xi < _width; xi++) {
        auto& cell = window.cell_at(x + xi, y + i);
        cell.fg = i == _selection? (TB_YELLOW | TB_REVERSE) : TB_DEFAULT;
        cell.bg = i == _selection? TB_REVERSE : TB_DEFAULT;
      }
    }
  }
};

class MessageBox : public TbWindow {
  std::string message;
public:
  MessageBox(const char* _message) : message(_message), TbWindow(measure_text_size(_message)) {;}
  virtual void draw_self() {
    draw_text(0, 0, message.c_str());
  }
};

class MessageBoxOk : public TbWindow {
  std::string message;
public:
  MessageBoxOk(const char* _message) : message(_message), TbWindow(resize(measure_text_size(_message), 0, 2)) {;}
  virtual void draw_self() {
    draw_text(0, 0, message.c_str());
    draw_hline(height() - 2);
    draw_text_center(height() - 1, "[ OK ]", TB_YELLOW | TB_REVERSE, TB_REVERSE);
  }
};

class Table {
  libscols_table* tb;
  libscols_line* last_line;
public:
  Table() : last_line(NULL) {
    tb = scols_new_table();
    if (!tb) RUNTIME_ERROR("Failed to allocate output table");
  }
  ~Table() { scols_unref_table(tb); }
  int noheadings(bool value) {
    return scols_table_enable_noheadings(tb, value? 1 : 0);
  }
  libscols_column* new_column(const char* colname, double hint, int flags) { return scols_table_new_column(tb, colname, hint, flags); }
  libscols_line* new_line(libscols_line* parent = NULL) {
    last_line = scols_table_new_line(tb, parent);
    if (!last_line) RUNTIME_ERROR("Failed to allocate output line");
    return last_line;
  }
  size_t get_nlines() { return scols_table_get_nlines(tb); }
  int print() { return scols_print_table(tb); }
  std::string print_string(size_t start, size_t end) {
    char* buf;
    scols_table_print_range_to_string(tb,
      scols_table_get_line(tb, start),
      scols_table_get_line(tb, end),
      &buf
    );
    std::string printed = buf;
    free(buf);
    return printed;
  }
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

inline std::string trim(const std::string &s)
{
   auto  wsfront=std::find_if_not(s.begin(),s.end(),[](int c){return std::isspace(c);});
   return std::string(wsfront,std::find_if_not(s.rbegin(),std::string::const_reverse_iterator(wsfront),[](int c){return std::isspace(c);}).base());
}

class ExternalProcess {
  std::stringstream output;
public:
  int fork_exec_wait(const char* cmd, const std::vector<std::string>& args);
  int fork_exec_wait(const char* cmd, ...);
  operator std::string() { return output.str(); }
};

bool is_file(const std::string& path);
bool is_block(const std::string& path);
bool is_dir(const std::string& path);

void exec_linux_console();
int ui(bool login = false);
int install(int argc, char* argv[]);
int installer();
int list(std::map<std::string,VM>& vms);
int start(int argc, char* argv[]);
int monitor(int argc, char* argv[]);
