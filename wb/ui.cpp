#include <limits.h>
#include <sys/sysmacros.h>
#include <sys/mount.h>
#include <glob.h>

#include <libmount/libmount.h>

#include <filesystem>
#include <fstream>

#include <pstream.h>
#define PICOJSON_USE_INT64
#include <picojson.h>

#include "wb.h"

std::pair<uint16_t, uint16_t> measure_text_size(const char* text)
{
  uint16_t x = 0, width = 0;
  uint16_t height = 1;
  const char* pt = text;
  while (*pt) {
    if (*pt == '\n') {
      if (x > width) width = x;
      x = 0;
      height++;
      pt++;
      continue;
    }
    int len = tb_utf8_char_length(*pt);
    if (len == TB_EOF) break;
    uint32_t ch;
    tb_utf8_char_to_unicode(&ch, pt);
    int w = wcwidth(ch);
    if (w < 1) w = 1;
    x += w;
    pt += len;
  }
  if (x > width) width = x;
  return std::make_pair(width, height);
}


void TbAbstractWindow::draw_text(int16_t x, int16_t y, const char* text, uint16_t fg/* = TB_DEFAULT*/, uint16_t bg/* = TB_DEFAULT*/) {
  const char* pt = text;
  while (*pt) {
    if (*pt == '\n') {
      x = 0;
      y ++;
      pt++;
      continue;
    }
    int len = tb_utf8_char_length(*pt);
    if (len == TB_EOF) break;
    uint32_t ch;
    tb_utf8_char_to_unicode(&ch, pt);
    int w = wcwidth(ch);
    if (w < 1) w = 1;
    if (x + w > _width) {
      y ++;
      x = 0;
    }
    change_cell(x, y, ch, fg, bg);
    x += w;
    pt += len;
  }
}

void TbAbstractWindow::draw_text_center(int16_t y, const char* text, uint16_t fg/* = TB_DEFAULT*/, uint16_t bg/* = TB_DEFAULT*/) {
  int16_t x = _width / 2 - measure_text_size(text).first / 2;
  draw_text(x, y, text, fg, bg);
}

void TbAbstractWindow::draw(TbAbstractWindow& dst, int16_t x, int16_t y, bool border/*=true*/)
{
  draw_self();
  for (uint16_t yi = 0; yi < _height; yi++) {
    for (uint16_t xi = 0; xi < _width; xi++){
      if (x + xi < 0 || x + xi >= dst.width() || y + yi < 0 || y + yi >= dst.height()) continue;
      dst.put_cell(x + xi, y + yi, cell_at(xi, yi));
    }
  }
  dst.change_cell(x - 1, y - 1, 0x250c); // ┌
  dst.change_cell(x + _width, y - 1, 0x2510); // 	┐
  dst.change_cell(x - 1, y + _height, 0x2514); // └
  dst.change_cell(x + _width, y + _height, 0x2518); // 	┘

  if (border) {
    for (uint16_t xi = 0 ; xi < _width; xi++) {
     // ─
      dst.change_cell(x + xi, y - 1, 0x2500);
      dst.change_cell(x + xi, y + _height, 0x2500);
    }

    for (uint16_t yi = 0; yi < _height; yi++) {
      // │
      dst.change_cell(x - 1, y + yi, 0x2502);
      dst.change_cell(x + _width, y + yi, 0x2502);
    }
  }
}

class MessageBox : public TbWindow {
  std::string message;
public:
  MessageBox(const char* _message) : message(_message), TbWindow(measure_text_size(_message)) {;}
  virtual void draw_self() {
    draw_text(0, 0, message.c_str());
  }
};

int ui(bool login/* = false*/)
{
  std::pair<bool, std::optional<int> > result;
  {
    Termbox termbox;
    TbRootWindow root = termbox.root();
    TbMenu<int> menu;
    menu.add_item(1, "シャットダウン");
    menu.add_item(2, "再起動");
    if (login) {
      menu.add_item(3, "Linuxコンソール");
    }
    menu.add_item(std::nullopt, "メニューを終了[ESC]");
    TbWindow window(menu.get_size());
    tb_event event;
    event.type = 0;
    menu.selection(0);
    while (!(result = menu.process_event(event)).first) {
      menu.draw(window);
      window.draw_center(root);
      termbox.present();
      termbox.poll_event(&event);
    }
  }

  if (!result.second) return 0;

  switch (result.second.value()) {
  case 1:
    execl("/sbin/poweroff", "/sbin/poweroff", NULL);
    break;
  case 2:
    execl("/sbin/reboot", "/sbin/reboot", NULL);
    break;
  case 3:
    return 9;
  default:
    RUNTIME_ERROR("menu");
  }
  return 0;
}

typedef std::tuple<std::string,std::string,uint64_t,std::string,uint16_t> PhysDisk;
const char* name(const PhysDisk& disk) { return std::get<0>(disk).c_str(); }
const char* model(const PhysDisk& disk) { return std::get<1>(disk).c_str(); }
uint64_t size(const PhysDisk& disk) { return std::get<2>(disk); }
const char* tran(const PhysDisk& disk) { return std::get<3>(disk).c_str(); }
uint16_t log_sec(const PhysDisk& disk) { return std::get<4>(disk); }

void get_install_candidates(std::list<PhysDisk>& disks,uint64_t least_size = 1024L * 1024 * 1024 * 4)
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

static bool is_bios_compatible(const PhysDisk& disk)
{
  return (size(disk) <= 2199023255552L/*2TiB*/ && log_sec(disk) == 512);
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

int glob(const char* pattern, int flags, int errfunc(const char *epath, int eerrno), std::list<std::filesystem::path>& match)
{
  glob_t globbuf;
  match.clear();
  int rst = glob(pattern, GLOB_NOESCAPE, NULL, &globbuf);
  if (rst == GLOB_NOMATCH) return 0;
  if (rst != 0) RUNTIME_ERROR("glob");
  //else
  for (int i = 0; i < globbuf.gl_pathc; i++) {
    match.push_back(std::filesystem::path(globbuf.gl_pathv[i]));
  }
  globfree(&globbuf);
  return match.size();
}

std::optional<std::string> get_partition(const char* disk, uint8_t num)
{
  if (!std::filesystem::is_block_file(disk)) RUNTIME_ERROR("Not a block device");

  struct stat s;
  if (stat(disk, &s) < 0) RUNTIME_ERROR_WITH_ERRNO("stat");

  char pattern[128];
  sprintf(pattern, "/sys/dev/block/%d:%d/*/partition",
    major(s.st_rdev), minor(s.st_rdev));

  std::list<std::filesystem::path> match;
  glob(pattern, GLOB_NOESCAPE, NULL, match);
  for (auto& path: match) {
    std::ifstream part(path);
    uint16_t partno;
    part >> partno;
    if (partno == num) {
      std::ifstream dev(path.replace_filename("dev"));
      std::string devno;
      dev >> devno;
      std::filesystem::path devblock("/dev/block/");
      auto devspecial = std::filesystem::read_symlink(devblock.replace_filename(devno));
      return devspecial.is_absolute()? devspecial : std::filesystem::canonical(devblock.replace_filename(devspecial));
    }
  }
  return std::nullopt;
}

class TempMount {
  std::filesystem::path path;
  std::string device, fstype, data;
  int flags;
  bool mounted;
protected:
  void do_mount() {
    struct libmnt_context *ctx = mnt_new_context();
    if (!ctx) RUNTIME_ERROR("mnt_new_context");
    // else
    mnt_context_set_fstype_pattern(ctx, fstype.c_str());
    mnt_context_set_source(ctx, device.c_str());
    mnt_context_set_target(ctx, path.c_str());
    mnt_context_set_mflags(ctx, flags);
    mnt_context_set_options(ctx, data.c_str());
    auto rst = mnt_context_mount(ctx);
    auto status1 = mnt_context_get_status(ctx);
    auto status2 = mnt_context_get_helper_status(ctx);
    mnt_free_context(ctx);
    if (rst > 1) RUNTIME_ERROR_WITH_ERRNO("mnt_context_mount");
    if (rst != 0) RUNTIME_ERROR("mnt_context_mount");
    //else
    if (status1 != 1) RUNTIME_ERROR("mnt_context_get_status");
    if (status2 != 0) RUNTIME_ERROR("mnt_context_get_helper_status");
    //else
    mounted = true;
  }
public:
  TempMount(const char* _device, const char* _fstype = "auto", int _flags = MS_RELATIME, const char* _data = "")
    : device(_device), fstype(_fstype), flags(_flags), data(_data), mounted(false) {
    path = std::filesystem::temp_directory_path() /= std::string("mount-") + std::to_string(getpid());
    std::filesystem::create_directory(path);
  }
  ~TempMount() {
    if (mounted) umount(path.c_str());
    std::filesystem::remove(path);
  }
  operator const std::filesystem::path&() {
    if (!mounted) do_mount();
    return path;
  }
  const char* c_str() { return ((const std::filesystem::path&)*this).c_str(); }
  std::filesystem::path operator /(const char* filename) {
    return ((std::filesystem::path)*this) /= filename;
  }
};

int exec_parted_script(const char* disk, const std::list<std::string>& commands)
{
  const char* parted = "/usr/sbin/parted";
  std::vector<std::string> args;
  args.push_back(parted);
  args.push_back("--script");
  args.push_back(disk);
  for (const auto& command : commands) {
    args.push_back(command);
  }
  return fork_exec_wait(parted, args);
}

int install(const PhysDisk& disk)
{
  bool bios_compatible = is_bios_compatible(disk);
  std::list<std::string> parted_commands;
  parted_commands.push_back((std::string)"mklabel " + (bios_compatible? "msdos" : "gpt"));
  if (size(disk) >= 35000000000L) {
    parted_commands.push_back("mkpart primary 1MiB 32GiB");
    parted_commands.push_back("mkpart primary 32GiB -1");
  } else {
    parted_commands.push_back("mkpart primary 1MiB -1");
  }
  parted_commands.push_back("set 1 boot on");
  if (bios_compatible) {
    parted_commands.push_back("set 1 esp on");
  }
  if (exec_parted_script(name(disk), parted_commands) != 0) {
    RUNTIME_ERROR("Partition setup failed");
  }

  fork_exec_wait("/bin/udevadm", "/bin/udevadm", "settle", NULL);

  auto boot_partition = get_partition(name(disk), 1);

  if (!boot_partition) {
    RUNTIME_ERROR("No boot partition");
    return 1;
  }

  if (fork_exec_wait("/usr/sbin/mkfs.vfat","/usr/sbin/mkfs.vfat", "-F","32",boot_partition.value().c_str(), NULL) != 0) {
    RUNTIME_ERROR("Formatting boot partition failed");
  }

  TempMount mnt(boot_partition.value().c_str(), "vfat", MS_RELATIME, "fmask=177,dmask=077");

  std::filesystem::create_directories(mnt / "efi/boot");
  std::filesystem::copy("/run/initramfs/boot/efi/boot/bootx64.efi", mnt / "efi/boot/bootx64.efi");
  fork_exec_wait("/usr/sbin/grub-install", "/usr/sbin/grub-install",
    "--target=i386-pc", "--recheck", ((std::string)"--boot-directory=" + (mnt / "boot").c_str()).c_str(),
    "--modules=xfs fat part_msdos normal linux echo all_video test multiboot2 search sleep gzio lvm chain configfile cpuid minicmd font terminal squash4 loopback videoinfo videotest blocklist probe gfxterm_background",
    name(disk), NULL);
  {
    std::ofstream grubcfg(mnt / "boot/grub/grub.cfg");
    if (grubcfg.fail()) RUNTIME_ERROR("ofstream");
    grubcfg << "insmod echo\ninsmod linux\ninsmod cpuid\n"
      << "set BOOT_PARTITION=$root\n"
      << "if cpuid -l; then\n\tloopback --offset1m loop /efi/boot/bootx64.efi\nelse\n\tloopback --offset1m loop /efi/boot/bootx86.efi\nfi\n"
      << "set root=loop\nset prefix=($root)/boot/grub\nnormal"
      << std::endl;
  }
  std::filesystem::copy("/run/initramfs/boot/system.img", mnt / "system.img");
  return 0;
}

int install(int argc, char* argv[]) noexcept(false)
{
  std::list<PhysDisk> disks;
  try {
    get_install_candidates(disks);
  }
  catch (const std::exception& e) {
    std::cerr << e.what() << std::endl;
    return 1;
  }

  std::pair<bool, std::optional<PhysDisk> > result;

  {
    Termbox termbox;
    TbRootWindow root = termbox.root();

    TbMenu<PhysDisk> menu;
    Table table;
    table.noheadings(true);
    table.new_column("NAME", 0.1, 0);
    table.new_column("MODEL", 0.1, 0);
    table.new_column("SIZE", 0.1, SCOLS_FL_RIGHT);
    table.new_column("TRAN", 0.1, 0);
    table.new_column("BOOT", 0.1, SCOLS_FL_RIGHT);

    TableLine line(table.new_line());
    line.set_data(0, "デバイス名");
    line.set_data(1, "モデル");
    line.set_data(2, "容量");
    line.set_data(3, "接続方式");
    line.set_data(4, "起動方式");

    for (const auto& disk : disks) {
      TableLine line(table.new_line());
      line.set_data(0, name(disk));
      line.set_data(1, model(disk));
      line.set_data(2, size_to_human_string(size(disk)));
      line.set_data(3, tran(disk));
      line.set_data(4, is_bios_compatible(disk)? "BIOS":"UEFI");
    }

    auto header = trim(table.print_string(0, 0));

    auto id = disks.cbegin();
    for (int i = 1; id != disks.cend(); i++, id++) {
      menu.add_item((*id), trim(table.print_string(i, i)).c_str());
    }
    menu.add_item(std::nullopt, "キャンセル[ESC]", true);

    auto header_size = measure_text_size(header.c_str());
    auto menu_size = menu.get_size();
    TbWindow window(std::max(header_size.first, menu_size.first), menu_size.second + 2);
    tb_event event;
    event.type = 0;
    menu.selection(0);
    while (!(result = menu.process_event(event)).first) {
      window.draw_text(0, 0, header.c_str());
      window.draw_hline(1);
      menu.draw(window, 0, 2);
      window.draw_center(root);
      termbox.present();
      termbox.poll_event(&event);
    }

    if (!result.second) return 1;
    //else
    termbox.clear();

    MessageBox msg("インストール中...");
    msg.draw_center(root);
    termbox.present();

    auto rst = install(result.second.value());
    if (rst != 0) return rst;
  }

  return 0;
}
