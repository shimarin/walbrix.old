#include <pty.h>
#include <glob.h>
#include <sys/stat.h>
#include <sys/mount.h>
#include <sys/sysmacros.h>

#include <set>
#include <fstream>

#include <libmount/libmount.h>
#include <blkid/blkid.h>

#include "sdlplusplus.h"
#include "wbc.h"
#include "installer.h"
#include "messagebox.h"
#include "terminal.h"

#include <pstream.h>
#define PICOJSON_USE_INT64
#include <picojson.h>

static void for_each_blockdevice(std::function<void(
    const std::string& name,
    std::optional<std::string> pkname,
    const std::string& type,
    std::optional<std::string> model,
    bool ro,
    uint64_t size,
    std::optional<std::string> tran,
    std::optional<uint16_t> log_sec,
    std::optional<std::filesystem::path> mountpoint)> func)
{
    redi::pstream in("lsblk -b -n -l -J -o NAME,MODEL,TYPE,PKNAME,RO,MOUNTPOINT,SIZE,TRAN,LOG-SEC");
    if (in.fail()) throw std::runtime_error("Failed to execute lsblk");
    // else
    picojson::value v;
    const std::string err = picojson::parse(v, in);
    if (!err.empty()) throw std::runtime_error(err);
    //else
    for (auto& _d : v.get<picojson::object>()["blockdevices"].get<picojson::array>()) {
        picojson::object& d = _d.get<picojson::object>();
        func(
            d["name"].get<std::string>(),
            d["pkname"].is<std::string>()? std::optional(d["pkname"].get<std::string>()) : std::nullopt,
            d["type"].get<std::string>(),
            d["model"].is<std::string>()? std::optional(d["model"].get<std::string>()) : std::nullopt,
            d["ro"].get<bool>(),
            d["size"].get<int64_t>(),
            d["tran"].is<std::string>()? std::optional(d["tran"].get<std::string>()) : std::nullopt,
            d["log-sec"].is<int64_t>()? std::optional(d["log-sec"].get<int64_t>()) : std::nullopt,
            d["mountpoint"].is<std::string>()? std::optional(std::filesystem::path(d["mountpoint"].get<std::string>())) : std::nullopt
        );
    }
};

void Installer::load_options()
{
    std::map<std::string,std::tuple<
        std::string/*name*/,std::optional<std::string>/*model*/,uint64_t/*size*/,std::optional<std::string>/*tran*/,uint16_t/*log_sec*/>
    > disks;
    std::set<std::string> to_be_removed;
    const uint64_t least_size = 1024L * 1024 * 1024 * 4;
    for_each_blockdevice([&disks,&to_be_removed](auto name, auto pkname, auto type, auto model, auto ro, auto size, auto tran, auto log_sec, auto mountpoint) {
        if (mountpoint) {
            if (pkname) to_be_removed.insert(pkname.value());
            return;
        }
        //else
        if (type != "disk" || size < least_size || !log_sec) return;
        //else
        disks[name] = { name, model, size, tran, log_sec.value() };
    });

    for (auto n : to_be_removed) {
        if (disks.contains(n)) disks.erase(n);
    }

    auto font = uicontext.registry.fonts({uicontext.FONT_PROPOTIONAL, 32});
    auto icon = uicontext.registry.surfaces("icon_storage.png");
    int y = 0;
    for (auto const& [_, disk] : disks) {
        (void)_;
        auto const& [ name, model, size, tran, log_sec ] = disk;
        auto const& [texture,__,h] = create_texture_from_surface(uicontext.renderer, [this,font,&icon,&name,&model,size]() {
            auto label_surface = make_shared(TTF_RenderUTF8_Blended(font, model? model.value().c_str() : (std::string("/dev/") + name).c_str(), {0,0,0,255}));
            std::string capacity_str;
            if (size > 1000L * 1000 * 1000 * 1000/*TB*/) {
                char buf[32];
                sprintf(buf, "%.1fTB", (double)size / 1000 / 1000 / 1000 / 1000);
                capacity_str = buf;
            } else /*GB*/ {
                char buf[32];
                sprintf(buf, "%.1fGB", (double)size / 1000 / 1000 / 1000);
                capacity_str = buf;
            }
            auto capacity_surface = make_shared(TTF_RenderUTF8_Blended(font, capacity_str.c_str(), {0,0,0,255}));

            return with_transparent_surface(width, std::max(label_surface->h, capacity_surface->h), [this,&icon,&label_surface, &capacity_surface](auto surface) {
                SDL_Rect rect { 0, (surface->h - icon->h) / 2, icon->w, icon->h };
                SDL_BlitSurface(icon, NULL, surface, &rect);

                rect.x += icon->w;
                rect.y = 0;
                rect.w = label_surface->w;
                rect.h = label_surface->h;
                if (rect.x + rect.w > surface->w - capacity_surface->w - 20) {
                    rect.w = surface->w - capacity_surface->w - rect.x - 20;
                }
                
                SDL_BlitScaled(label_surface.get(), NULL, surface, &rect);
                rect.x = width - capacity_surface->w;
                rect.w = capacity_surface->w;
                rect.h = capacity_surface->h;
                SDL_BlitSurface(capacity_surface.get(), NULL, surface, &rect);
            });
        });
        (void)__;
        options.push_back({name, size, log_sec, texture, y, h, model? model.value() : ""});
        y += h;
    }
}

void Installer::on_select()
{
    load_options();
}

void Installer::on_deselect()
{
    options.clear();
}

void Installer::draw(SDL_Renderer* renderer/*=NULL*/)
{
    if (!renderer) renderer = uicontext.renderer;
    for (auto const&[name, size, log_sec, texture, y, h, details] : options) {
        (void)size;(void)log_sec;
        SDL_Rect rect { uicontext.mainmenu_width, uicontext.header_height + y, width, h };
        SDL_RenderCopy(renderer, texture.get(), NULL, &rect);
    }
}

static void exec_command(const std::string& cmd, const std::vector<std::string>& args)
{
    if (geteuid() != 0) { // just print command if not root
        std::cout << cmd;
        for (auto arg : args) {
            std::cout << " '" << arg << "'";
        }
        std::cout << std::endl;
        return;
    }
    //else
    pid_t pid = fork();
    if (pid < 0) std::runtime_error("fork");
    //else
    if (pid == 0) { //child
        char* argv[args.size() + 2];
        int i = 0;
        argv[i++] = strdup(cmd.c_str());
        for (auto arg : args) {
            argv[i++] = strdup(arg.c_str());
        }
        argv[i] = NULL;
        if (execvp(cmd.c_str(), argv) < 0) _exit(-1);
    }
    // else {
    int status;
    waitpid(pid, &status, 0);
    if (status != 0) throw std::runtime_error(cmd);
}

static int glob(const char* pattern, int flags, int errfunc(const char *epath, int eerrno), std::list<std::filesystem::path>& match)
{
  glob_t globbuf;
  match.clear();
  int rst = glob(pattern, GLOB_NOESCAPE, NULL, &globbuf);
  if (rst == GLOB_NOMATCH) return 0;
  if (rst != 0) throw std::runtime_error("glob");
  //else
  for (int i = 0; i < globbuf.gl_pathc; i++) {
    match.push_back(std::filesystem::path(globbuf.gl_pathv[i]));
  }
  globfree(&globbuf);
  return match.size();
}

static std::optional<std::filesystem::path> get_partition(const std::filesystem::path& disk, uint8_t num)
{
  if (!std::filesystem::is_block_file(disk)) throw std::runtime_error("Not a block device");

  struct stat s;
  if (stat(disk.c_str(), &s) < 0) throw std::runtime_error("stat");

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

template <typename T> T with_tempmount(const std::filesystem::path& device, const char* fstype, int flags, const char* data,
    std::function<T(const std::filesystem::path&)> func)
{
    struct libmnt_context *ctx = mnt_new_context();
    if (!ctx) throw std::runtime_error("mnt_new_context");
    // else

    auto path = std::filesystem::temp_directory_path() /= std::string("mount-") + std::to_string(getpid());
    std::filesystem::create_directory(path);
    mnt_context_set_fstype_pattern(ctx, fstype);
    mnt_context_set_source(ctx, device.c_str());
    mnt_context_set_target(ctx, path.c_str());
    mnt_context_set_mflags(ctx, flags);
    mnt_context_set_options(ctx, data);
    auto rst = mnt_context_mount(ctx);
    auto status1 = mnt_context_get_status(ctx);
    auto status2 = mnt_context_get_helper_status(ctx);
    mnt_free_context(ctx);
    if (rst > 1) throw std::runtime_error("mnt_context_mount");
    if (rst != 0) throw std::runtime_error("mnt_context_mount");
    //else
    if (status1 != 1) throw std::runtime_error("mnt_context_get_status");
    if (status2 != 0) throw std::runtime_error("mnt_context_get_helper_status");
    //else
    try {
        auto rst = func(path);
        umount(path.c_str());
        std::filesystem::remove(path);
        return rst;
    }
    catch (...) {
        umount(path.c_str());
        std::filesystem::remove(path);
        throw;
    }
}

static std::optional<std::string> get_partition_uuid(const std::filesystem::path& partition)
{
  blkid_cache cache;
  if (blkid_get_cache(&cache, "/dev/null") != 0) return std::nullopt;
  // else
  std::optional<std::string> rst = std::nullopt;
  if (blkid_probe_all(cache) == 0) {
    auto tag_value = blkid_get_tag_value(cache, "UUID", partition.c_str());
    if (tag_value) rst = tag_value;
  }
  blkid_put_cache(cache);
  return rst;
}

static void do_install(const std::filesystem::path& disk, uint64_t size, uint16_t log_sec)
{
    std::cout << "LVMを停止します" << std::endl;
    exec_command("vgchange", {"-an"});

    std::vector<std::string> parted_args = {"--script", disk.string()};
    bool bios_compatible = (size <= 2199023255552L/*2TiB*/ && log_sec == 512);
    parted_args.push_back(bios_compatible? "mklabel msdos" : "mklabel gpt");
    bool has_secondary_partition = size >= 9000000000L; // more than 8GiB

    if (has_secondary_partition) {
        parted_args.push_back("mkpart primary fat32 1MiB 8GiB");
        parted_args.push_back("mkpart primary btrfs 8GiB -1");
    } else {
        std::cout << "警告: ディスク容量が小さいためデータ領域は作成されません" << std::endl;
        parted_args.push_back("mkpart primary fat32 1MiB -1");
    }
    parted_args.push_back("set 1 boot on");
    if (bios_compatible) {
        parted_args.push_back("set 1 esp on");
    }

    std::cout << "パーティションを作成しています...";
    std::flush(std::cout);
    exec_command("parted", parted_args);
    exec_command("udevadm", {"settle"});
    std::cout << "完了" << std::endl;

    auto _boot_partition = get_partition(disk, 1);
    if (!_boot_partition) {
        std::cerr << "エラー: 起動パーティションを特定できません" << std::endl;
        throw std::runtime_error("No boot partition");
    }
    //else
    auto boot_partition = _boot_partition.value();

    std::cout << "起動パーティションをFAT32でフォーマットします" << std::endl;
    exec_command("mkfs.vfat",{"-F","32",boot_partition});

    std::cout << "起動パーティションをマウントしています...";
    std::flush(std::cout);
    with_tempmount<bool>(boot_partition, "vfat", MS_RELATIME, "fmask=177,dmask=077", [&disk,bios_compatible](auto mnt) {
        std::cout << "完了" << std::endl;
        std::cout << "ブートローダー(UEFI)をインストールします" << std::endl;
        auto efi_boot = mnt / "efi/boot";
        std::filesystem::create_directories(efi_boot);
        exec_command("grub-mkimage", {"-p", "/boot/grub", "-o", (efi_boot / "bootx64.efi").string(), "-O", "x86_64-efi", 
            "xfs","fat","part_gpt","part_msdos","normal","linux","echo","all_video","test","multiboot","multiboot2","search","sleep","iso9660","gzio",
            "lvm","chain","configfile","cpuid","minicmd","gfxterm_background","png","font","terminal","squash4","loopback","videoinfo","videotest",
            "blocklist","probe","efi_gop","efi_uga", "keystatus"});
        if (bios_compatible) {
            std::cout << "ブートローダー(BIOS)をインストールします" << std::endl;
            exec_command("grub-install", {"--target=i386-pc", "--recheck", std::string("--boot-directory=") + (mnt / "boot").string(),
                "--modules=xfs fat part_msdos normal linux echo all_video test multiboot multiboot2 search sleep gzio lvm chain configfile cpuid minicmd font terminal squash4 loopback videoinfo videotest blocklist probe gfxterm_background png keystatus",
                disk.string()});
        } else {
            std::cout << "BIOSで扱えないタイプのディスクなのでこのシステムはUEFI専用となります" << std::endl;
        }
        std::cout << "ブート設定ファイルを作成します" << std::endl;
        {
            std::ofstream grubcfg(mnt / "boot/grub/grub.cfg");
            if (grubcfg.fail()) throw std::runtime_error("ofstream('/boot/grub/grub.cfg')");
            grubcfg << "insmod echo\ninsmod linux\ninsmod cpuid\n"
                << "set BOOT_PARTITION=$root\n"
                << "loopback loop /system.img\n"
                << "set root=loop\nset prefix=($root)/boot/grub\nnormal"
                << std::endl;
        }

        std::cout << "システムファイルをコピーします" << std::endl;
        std::filesystem::path run_initramfs_boot("/run/initramfs/boot");
        char buf[128 * 1024];
        FILE* f1 = fopen((run_initramfs_boot / "system.img").c_str(), "r");
        if (!f1) throw std::runtime_error("Unable to open system file");
        //else
        struct stat statbuf;
        if (fstat(fileno(f1), &statbuf) < 0 || statbuf.st_size == 0) {
            fclose(f1);
            throw std::runtime_error("Unable to stat system file");
        }
        FILE* f2 = fopen((mnt / "system.img").c_str(), "w");
        size_t r;
        size_t cnt = 0;
        uint8_t percentage = 0;
        do {
            r = fread(buf, 1, sizeof(buf), f1);
            fwrite(buf, 1, r, f2);
            fflush(f2);
            fdatasync(fileno(f2));
            cnt += r;
            std::flush(std::cout);
            uint8_t new_percentage = cnt * 100 / statbuf.st_size;
            if (new_percentage > percentage) {
                percentage = new_percentage;
                std::cout << "\rコピー中..." << (int)percentage << "%";
                std::flush(std::cout);
            }
        } while (r == sizeof(buf));
        std::cout << std::endl;
        fclose(f1);
        fclose(f2);
        std::cout << "起動パーティションをアンマウントしています...";
        std::flush(std::cout);
        return true;
    });
    std::cout << "完了" << std::endl;
    
    if (has_secondary_partition) {
        std::cout << "データ領域を構築します" << std::endl;
        auto secondary_partition = get_partition(disk, 2);
        if (secondary_partition) {
            auto boot_partition_uuid = get_partition_uuid(boot_partition);
            if (boot_partition_uuid) {
                auto label = std::string("wbdata-") + boot_partition_uuid.value();
                auto partition_name = secondary_partition.value();
                std::cout << "データ領域用パーティション " << partition_name.string() << " をBTRFSでフォーマットしています(ラベル=" << label << ")...";
                std::flush(std::cout);
                exec_command("mkfs.btrfs", {"-q", "-L", label, "-f", partition_name.string()});
                std::cout << "完了" << std::endl;
            } else {
                std::cout << "警告: 起動パーティションのUUIDを取得できません。データ領域は作成されません" << std::endl;
            }
        } else {
            std::cout << "警告: データ領域用のパーティションを特定できません。データ領域は作成されません" << std::endl;
        }
    }

}

static bool do_install(UIContext& uicontext, const std::filesystem::path& disk, uint64_t size, uint16_t log_sec)
{
    const int rows = 24, cols = 60;

    int fd;
    struct winsize win = { (unsigned short)rows, (unsigned short)cols, 0, 0 };
    auto pid = forkpty(&fd, NULL, NULL, &win);
    if (pid < 0) throw std::runtime_error("forkpty failed");
    //else
    if (!pid) {
        signal(SIGTERM, SIG_DFL);
        signal(SIGINT, SIG_DFL);
        int fdlimit = (int)sysconf(_SC_OPEN_MAX);
        for (int i = STDERR_FILENO + 1; i < fdlimit; i++) close(i);
        setenv("TERM", "xterm-256color", 1);
        std::cout << "Walbrixを " << disk.string() << " へインストールします" << std::endl;
        try {
            do_install(disk, size, log_sec);
            std::cout << "インストール完了" << std::endl;
        }
        catch (const std::runtime_error& e) {
            std::cerr << "エラー:" << e.what() << std::endl;
            std::cout << "Enterキーを押してください: ";
            getchar();
            _Exit(-1);
        }
        _Exit(0);//success
    }
    //else 

    struct AutoClose {
        int fd;
        AutoClose(int _fd) : fd(_fd) {;}
        ~AutoClose() { close(fd); }
    } autoclose_fd(fd);

    auto font = uicontext.registry.fonts({uicontext.FONT_FIXED, 24});
    Terminal terminal(fd, rows, cols, font);
    SDL_Rect terminal_rect = { 
        uicontext.mainmenu_width, uicontext.header_height, 
        uicontext.width - uicontext.mainmenu_width, uicontext.height - uicontext.header_height - uicontext.footer_height
    };

    uicontext.push_render_func([&terminal,&terminal_rect](auto renderer, bool) {
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        SDL_RenderFillRect(renderer, &terminal_rect);
        terminal.render(renderer, terminal_rect);
        return true;
    });

    int status;
    while (pid != waitpid(pid, &status, WNOHANG)) {
        uicontext.render();

        process_event([&terminal](auto ev) { terminal.processEvent(ev); return true; } );
        if (!terminal.processInput()) break; // EOF detected

        SDL_RenderPresent(uicontext.renderer);
    }
    terminal.processInput(); // to consume last output from subprocess

    if (status == 0) {
        messagebox_okcancel(uicontext, "インストールできました");
    } else {
        messagebox_okcancel(uicontext, "インストールが中断されました", true, true);
    }

    uicontext.pop_render_func();
    return (status == 0);
}

bool Installer::on_enter()
{
    options.clear();
    load_options();
    if (options.size() < 1) return true;

    int selected = 0;

    auto cursor = create_texture_from_surface(uicontext.renderer, 1, 1, [](auto surface) { 
        SDL_FillRect(surface, NULL, SDL_MapRGB(surface->format, 0x07, 0x8e, 0xb7));
    });

    uicontext.push_render_func([this,&cursor,&selected](auto renderer, bool focus) {
        auto const& [name, size, log_sec, texture, y, h, details] = options[selected];
        (void)name;(void)size;(void)log_sec;(void)texture;(void)details;
        SDL_Rect rect { uicontext.mainmenu_width, uicontext.header_height + y, width, h};
        Uint8 alpha = focus? (std::abs(std::sin((SDL_GetTicks() % 4000 * pi * 2 / 4000))) * 127 + 128) : 255;
        SDL_SetTextureAlphaMod(cursor.get(), alpha);
        SDL_RenderCopy(renderer, cursor.get(), NULL, &rect);
        draw(renderer);
        return true;
    });

    while (true) {
        while (process_event([this,&selected](auto ev) {
            if (ev.type != SDL_KEYDOWN) return true;
            //else
            if (ev.key.keysym.sym == SDLK_UP && selected > 0) {
                selected--;
            } else if (ev.key.keysym.sym == SDLK_DOWN && selected < options.size() - 1) {
                selected++;
            } else if (ev.key.keysym.sym == SDLK_RETURN || ev.key.keysym.sym == SDLK_KP_ENTER) {
                return false;
            } else if (ev.key.keysym.sym == SDLK_ESCAPE) {
                selected = -1;
                return false;
            }        
            return true;
        })) {
            uicontext.render();
            SDL_RenderPresent(uicontext.renderer);
        }
        if (selected < 0 || (selected >= 0 && messagebox_okcancel(uicontext, "インストールします", false, true))) break;
    }

    uicontext.pop_render_func();

    if (selected < 0) return true;
    //else
    auto const& [name, size, log_sec, texture, y, h, details] = options[selected];
    (void)texture,(void)y,(void)h,(void)details;
    auto const& disk = std::filesystem::path("/dev/") / name;
    if (do_install(uicontext, disk, size, log_sec)) throw PerformReboot();
    //else
    return true;
}
