#include <filesystem>
#include <fstream>

#include <limits.h>
#include <sys/sysmacros.h>
#include <sys/mount.h>
#include <glob.h>

#include <libmount/libmount.h>

#include <pstream.h>
#define PICOJSON_USE_INT64
#include <picojson.h>

#include "wb.h"

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

int install(ExternalProcess& process, const PhysDisk& disk)
{
  const char* parted = "/usr/sbin/parted";
  std::vector<std::string> parted_args;
  parted_args.push_back(parted);
  parted_args.push_back("--script");
  parted_args.push_back(name(disk));

  bool bios_compatible = is_bios_compatible(disk);
  parted_args.push_back((std::string)"mklabel " + (bios_compatible? "msdos" : "gpt"));

  bool has_secondary_partition = size(disk) >= 35000000000L;

  if (has_secondary_partition) {
    parted_args.push_back("mkpart primary 1MiB 32GiB");
    parted_args.push_back("mkpart primary 32GiB -1");
    parted_args.push_back("set 2 lvm on");
  } else {
    parted_args.push_back("mkpart primary 1MiB -1");
  }
  parted_args.push_back("set 1 boot on");
  if (bios_compatible) {
    parted_args.push_back("set 1 esp on");
  }

  if (process.fork_exec_wait(parted, parted_args) != 0) {
    RUNTIME_ERROR("Partition setup failed");
  }

  process.fork_exec_wait("/bin/udevadm", "/bin/udevadm", "settle", NULL);

  auto boot_partition = get_partition(name(disk), 1);

  if (!boot_partition) {
    RUNTIME_ERROR("No boot partition");
    return 1;
  }

  if (process.fork_exec_wait("/usr/sbin/mkfs.vfat","/usr/sbin/mkfs.vfat", "-F","32",boot_partition.value().c_str(), NULL) != 0) {
    RUNTIME_ERROR("Formatting boot partition failed");
  }

  TempMount mnt(boot_partition.value().c_str(), "vfat", MS_RELATIME, "fmask=177,dmask=077");

  std::filesystem::create_directories(mnt / "efi/boot");
  std::filesystem::path run_initramfs_boot("/run/initramfs/boot");
  std::filesystem::copy(run_initramfs_boot / "efi/boot/bootx64.efi", mnt / "efi/boot/bootx64.efi");
  process.fork_exec_wait("/usr/sbin/grub-install", "/usr/sbin/grub-install",
    "--target=i386-pc", "--recheck", ((std::string)"--boot-directory=" + (mnt / "boot").c_str()).c_str(),
    "--modules=xfs fat part_msdos normal linux echo all_video test multiboot multiboot2 search sleep gzio lvm chain configfile cpuid minicmd font terminal squash4 loopback videoinfo videotest blocklist probe gfxterm_background png",
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

  auto system_ini = run_initramfs_boot / "system.ini";
  if (is_file(system_ini)) {
    std::filesystem::copy_file(system_ini, mnt / system_ini.filename());
  }
  auto openvpn = run_initramfs_boot / "openvpn";
  if (is_dir(openvpn)) {
    process.fork_exec_wait("/bin/cp", "/bin/cp", "-a", openvpn.c_str(), mnt.c_str(), NULL);
  }

  if (has_secondary_partition) {
    auto secondary_partition = get_partition(name(disk), 2);
    if (secondary_partition) {
      const char* partition_name = secondary_partition.value().c_str();
      if (process.fork_exec_wait("/sbin/pvcreate", "/sbin/pvcreate", "-ffy", partition_name, NULL) == 0) {
        process.fork_exec_wait("/sbin/vgcreate", "/sbin/vgcreate", "--yes", "--addtag=@wbvg", "wbvg", partition_name, NULL);
      }
    }
  }

  return 0;
}

int install(bool reboot_after_done = false)
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

  ExternalProcess process;
  int rst;

  {
    Termbox termbox;
    TbRootWindow root = termbox.root();

    if (disks.size() == 0) {
      MessageBoxOk msgbox("インストール可能なディスクがありません。");
      msgbox.draw_center(root);
      termbox.present();
      termbox.wait_for_enter_or_esc_key();
      termbox.clear();
      return 1;
    }
    //else

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
    TbWindow window(std::max(header_size.first, menu_size.first), menu_size.second + 2, "インストール先の選択");
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

    {
      MessageBox msgbox("インストール中...");
      msgbox.draw_center(root);
      termbox.present();

      rst = install(process, result.second.value());
      termbox.clear();
    }

    {
      std::string msg;
      if (rst == 0) {
        msg = "インストールが完了しました。";
        if (reboot_after_done) {
          msg += "\nインストールディスクをドライブから取り出してください。\nOK でコンピュータを再起動します。";
        }
      } else {
        msg = "インストールに失敗しました。\n";
        msg += process;
      }
      MessageBoxOk msgbox(msg.c_str());
      msgbox.draw_center(root);
      termbox.present();
      while (true) {
        if (termbox.poll_event(&event) != TB_EVENT_KEY) continue;
        if (event.key == TB_KEY_ENTER || event.key == TB_KEY_ESC) break;
      }
      termbox.clear();
    }

  }

  if (reboot_after_done) {
    execl("/sbin/reboot", "/sbin/reboot", "-f", NULL);
  }
  //std::cout << (std::string)process << std::endl;

  return rst;
}

int install(int argc, char* argv[]) noexcept(false)
{
  return install(false);
}

int installer()
{
  std::pair<bool, std::optional<int> > result;
  {
    Termbox termbox;
    TbRootWindow root = termbox.root();
    TbMenu<int> menu;
    menu.add_item(1, "インストールを開始");
    menu.add_item(2, "Linuxコンソール");
    menu.add_item(3, "シャットダウン");
    menu.add_item(4, "再起動");
    TbWindow window(resize(menu.get_size(), 5, 0), "Walbrixインストーラー");
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
    return install(true);
  case 2:
    exec_linux_console();
    break;
  case 3:
    execl("/sbin/poweroff", "/sbin/poweroff", "-f", NULL);
    break;
  case 4:
    execl("/sbin/reboot", "/sbin/reboot", "-f", NULL);
    break;
  default:
    RUNTIME_ERROR("menu");
  }
  return 0;
}
