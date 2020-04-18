#include <sys/wait.h>
#include <sys/reboot.h>
#include <sys/statvfs.h>
#include <string.h>
#include <stdarg.h>
#include <fcntl.h>
#include <unistd.h>

#include <libmount/libmount.h>
#include <blkid/blkid.h>

#include <iostream>
#include <fstream>
#include <filesystem>
#include <exception>

#include "initlib.h"

#define UMOUNT "/bin/umount"
#define FSCK_FAT "/usr/sbin/fsck.fat"
#define MKFS_BTRFS "/sbin/mkfs.btrfs"
#define BTRFS "/sbin/btrfs"
#define SWITCH_ROOT "/sbin/switch_root"
#define MKSWAP "/sbin/mkswap"
#define SWAPON "/sbin/swapon"
#define PASSWD "/usr/bin/passwd"
#define CHPASSWD "/usr/sbin/chpasswd"
#define TIME_FILE "boottime.txt"

class LibMntContext {
  libmnt_context* ctx;
public:
  LibMntContext() {
    ctx = mnt_new_context();
    if (!ctx) RUNTIME_ERROR_WITH_ERRNO("mnt_new_context");
  }
  ~LibMntContext() { if (ctx) {mnt_free_context(ctx);} }
  operator libmnt_context*() { return ctx; }
  int do_mount_and_check_result() {
    int rst = mnt_context_mount(ctx);
    if (rst != 0) {
      if (rst > 1) perror("mnt_context_mount");
      return rst;
    }
    //else
    return mnt_context_get_status(ctx) == 1? 0 : -1;
  }
};

int mount(const std::filesystem::path& source,
  const std::filesystem::path& mountpoint,
  const std::string& fstype/* = "auto"*/, unsigned int mountflags/* = MS_RELATIME*/,
  const std::string& data/* = ""*/)
{
  LibMntContext ctx;
  mnt_context_set_fstype_pattern(ctx, fstype.c_str());
  mnt_context_set_source(ctx, source.c_str());
  mnt_context_set_target(ctx, mountpoint.c_str());
  mnt_context_set_mflags(ctx, mountflags);
  mnt_context_set_options(ctx, data.c_str());

  return ctx.do_mount_and_check_result();
}

int umount(const std::filesystem::path& mountpoint)
{
  return umount(mountpoint.c_str());
}

int mount_loop(std::filesystem::path source, std::filesystem::path mountpoint,
  const std::string& fstype/* = "auto"*/, unsigned int mountflags/* = MS_RELATIME*/,
  const std::string& data/* = ""*/, int offset/* = 0*/)
{
  auto data_loop = data == "" ? std::string("") : data + ",";
  data_loop += "loop,offset=";
  data_loop += std::to_string(offset);
  return mount(source, mountpoint, fstype, mountflags, data_loop.c_str());
}

class BlkidDevIterate {
  blkid_dev_iterate iter;
  blkid_cache cache;
public:
  BlkidDevIterate() {
    blkid_get_cache(&cache, "/dev/null");
    blkid_probe_all(cache);
    iter = blkid_dev_iterate_begin(cache);
  }
  ~BlkidDevIterate() {
    blkid_dev_iterate_end(iter);
    blkid_put_cache(cache);
  }
  operator blkid_dev_iterate() { return iter; }
  blkid_dev verify(blkid_dev dev) { return blkid_verify(cache, dev); }
};

class BlkIdTagIterate {
  blkid_tag_iterate iter;
public:
  BlkIdTagIterate(blkid_dev dev) {
    iter = blkid_tag_iterate_begin(dev);
  }
  ~BlkIdTagIterate() {
    blkid_tag_iterate_end(iter);
  }
  operator blkid_tag_iterate() { return iter; }
};

std::optional<Partition> search_partition(const std::string& name, const std::string& value)
{
  BlkidDevIterate iter;
  blkid_dev_set_search(iter, name.c_str(), value.c_str());
  blkid_dev dev = NULL;
  while (blkid_dev_next(iter, &dev) == 0) {
    dev = iter.verify(dev);
    if (dev) break;
  }
  if (!dev) return std::nullopt;
  //else
  std::optional<std::string> fstype = std::nullopt;
  BlkIdTagIterate tag_iter(dev);
  const char *_type, *_value;
  while (blkid_tag_next(tag_iter, &_type, &_value) == 0) {
    if (strcmp(_type,"TYPE") == 0) {
      fstype = _value;
      break;
    }
  }
  return Partition { blkid_dev_devname(dev), fstype };
}

bool is_block_readonly(const std::filesystem::path& path)
{
  if (!std::filesystem::is_block_file(path)) RUNTIME_ERROR("Not a block device");
  //else
  int fd = open(path.c_str(), O_RDONLY);
  if (fd < 0) RUNTIME_ERROR_WITH_ERRNO("open");
  //else
  int readonly;
  if (ioctl(fd, BLKROGET, &readonly) < 0) RUNTIME_ERROR_WITH_ERRNO("ioctl");
  // else
  close(fd);
  return readonly;
}

bool is_file(const std::filesystem::path& path)
{
  if (!std::filesystem::exists(path)) return false;
  return std::filesystem::is_regular_file(path);
}

int rename(const std::filesystem::path& old, const std::filesystem::path& _new)
{
  return ::rename(old.c_str(), _new.c_str());
}

int mount_overlay(const std::filesystem::path& lowerdir, const std::filesystem::path& upperdir, const std::filesystem::path& workdir,
  const std::filesystem::path& mountpoint)
{
  std::stringstream buf;
  buf << "lowerdir=" << lowerdir.c_str()
    << ",upperdir=" << upperdir.c_str()
    << ",workdir=" << workdir.c_str();
  std::string data = buf.str();
  return mount("overlay", mountpoint, "overlay", MS_RELATIME, data.c_str());
}

int move_mount(const std::filesystem::path& old, const std::filesystem::path& _new)
{
  return mount(old.c_str(), _new.c_str(), NULL, MS_MOVE, NULL);
}

int switch_root(const char *newroot)
{
  return execl(SWITCH_ROOT, SWITCH_ROOT, newroot, "/sbin/init", NULL);
}

struct ForkExecOptions {
  std::optional<std::filesystem::path> rootdir = std::nullopt;
  std::optional<std::string> data = std::nullopt;
};

int fork_exec_wait(const char* cmd, const std::vector<std::string>& args,
  std::optional<ForkExecOptions> options = std::nullopt)
{
  char* argv[args.size() + 1];
  for (int i = 0; i < args.size(); i++) {
    argv[i] = (char*)/*argggh*/args[i].c_str();
  }
  argv[args.size()] = NULL;

  int fd[2];
  if (options && options.value().data) {
    pipe(fd);
  }

  pid_t pid = fork();
  if (pid < 0) RUNTIME_ERROR_WITH_ERRNO("fork");
  //else
  int rst;
  if (pid == 0) { //child
    if (options && options.value().rootdir) {
      if (chroot(options.value().rootdir.value().c_str()) < 0) _exit(-1);
    }
    if (execv(cmd, argv) < 0) _exit(-1);
  } else { // parent
    if (options && options.value().data) {
      const auto& data = options.value().data;
      close(fd[0]);
      write(fd[1], data.value().c_str(), data.value().length());
      close(fd[1]);
    }
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

int fork_chroot_exec_wait(const std::filesystem::path& rootdir, const char* cmd, ...)
{
  std::vector<std::string> args;

  va_list list;
  va_start(list, cmd);
  char* arg;
  while ((arg = va_arg(list, char *)) != NULL) {
    args.push_back(arg);
  }
  va_end(list);
  return fork_chroot_exec_wait(rootdir, cmd, args, ForkExecOptions {rootdir, std::nullopt});
}

int fork_chroot_exec_write_wait(const std::filesystem::path& rootdir, const std::string& data, const char *cmd, ...)
{
  std::vector<std::string> args;

  va_list list;
  va_start(list, cmd);
  char* arg;
  while ((arg = va_arg(list, char *)) != NULL) {
    args.push_back(arg);
  }
  va_end(list);
  return fork_chroot_exec_wait(rootdir, cmd, args, ForkExecOptions {rootdir, data});
}

int umount_recursive(const std::filesystem::path& path)
{
  return fork_exec_wait(UMOUNT, UMOUNT, "-R", "-n", path.c_str(), NULL);
}

int unlink(const std::filesystem::path& path)
{
  return unlink(path.c_str());
}

int create_zero_filled_file(const std::filesystem::path& path, off_t length)
{
  int fd = creat(path.c_str(), S_IRUSR | S_IWUSR);
  if (fd < 0) return fd;
  //else
  int rst = ftruncate(fd, length);
  close(fd);
  return rst;
}

int create_btrfs_imagefile(const std::filesystem::path& imagefile, off_t length)
{
  int rst = create_zero_filled_file(imagefile, length);
  if (rst != 0) return rst;
  // else
  return fork_exec_wait(MKFS_BTRFS, MKFS_BTRFS, "-f", "-q", imagefile.c_str(), NULL);
}

int repair_btrfs(const std::filesystem::path& path)
{
  return fork_exec_wait(BTRFS, BTRFS, "check", "--repair", "--force", path.c_str(), NULL);
}

int btrfs_scan()
{
  return fork_exec_wait(BTRFS, BTRFS, "device", "scan", NULL);
}

int create_swapfile(const std::filesystem::path& swapfile, off_t length)
{
  int rst = create_zero_filled_file(swapfile, length);
  if (rst < 0) return rst;
  //else
  return fork_exec_wait(MKSWAP, MKSWAP, swapfile.c_str(), NULL);
}

int activate_swap(const std::filesystem::path& swapfile)
{
  if (fork_exec_wait(SWAPON, SWAPON, swapfile.c_str(), NULL) != 0) {
    std::cout << "Broken swapfile? performing mkswap..." << std::endl;
    if (fork_exec_wait(MKSWAP, MKSWAP, swapfile.c_str(), NULL) == 0) {
      return fork_exec_wait(SWAPON, SWAPON, swapfile.c_str(), NULL);
    }
  }
  return 0;
}

class LibMntTable {
  libmnt_table* tb;
public:
  LibMntTable() : tb(mnt_new_table_from_file("/proc/self/mountinfo")) {

  }
  ~LibMntTable() { if (!tb) mnt_unref_table(tb); }
  operator libmnt_table*() { return tb; }
};

std::optional<std::string> get_source_device_from_mountpoint(const std::filesystem::path& path)
{
  LibMntTable tb;
  //struct libmnt_table *tb = mnt_new_table_from_file("/proc/self/mountinfo");
  libmnt_cache *cache = mnt_new_cache();
  mnt_table_set_cache(tb, cache);
	mnt_unref_cache(cache);

  int rst = -1;
  libmnt_fs* fs = mnt_table_find_target(tb, path.c_str(), MNT_ITER_BACKWARD);
  return fs? std::optional(mnt_fs_get_srcpath(fs)) : std::nullopt;
}

int repair_fat(const std::filesystem::path& path)
{
  return fork_exec_wait(FSCK_FAT, FSCK_FAT, "-a", "-w", path.c_str(), NULL);
}

uint64_t get_free_disk_space(const std::filesystem::path& mountpoint)
{
  struct statvfs s;
  if (statvfs(mountpoint.c_str(), &s) < 0) RUNTIME_ERROR_WITH_ERRNO("statvfs");
  //else
  return (uint64_t)s.f_bsize * s.f_bfree;
}

int set_hostname(const std::filesystem::path& rootdir, const std::string& hostname)
{
  std::ofstream f(rootdir / "etc/hostname");
  if (!f) return -1;
  //else
  f << hostname;
  return 0;
}

std::string generate_default_hostname(const std::string& prefix = "host")
{
  FILE *f;
  uint16_t randomnumber;
  f = fopen("/dev/urandom", "r");
  if (!f) return prefix + "-XXXX";
  //else
  fread(&randomnumber, sizeof(randomnumber), 1, f);
  fclose(f);
  char hostname[16];
  sprintf(hostname, "%s-%04x", prefix.c_str(), randomnumber);
  return hostname;
}

int set_root_password(const std::filesystem::path& rootdir, const std::string& password/* "" to remove password*/)
{
  if (password == "") { // remove password
    return fork_chroot_exec_wait(rootdir, PASSWD, PASSWD, "-d", "root", NULL);
  }
  // else
  std::string buf("root:");
  buf += password;
  return fork_chroot_exec_write_wait(rootdir, buf.c_str(), CHPASSWD, CHPASSWD, NULL);
}

Init::Init() : ini(NULL)
{
}

Init::~Init()
{
  if (ini) iniparser_freedict(ini);
}

void Init::setup()
{
  std::filesystem::create_directory("/proc");
  if (mount("proc", "/proc", "proc", MS_NOEXEC|MS_NOSUID|MS_NODEV) != 0)
    RUNTIME_ERROR("mount /proc");
  std::filesystem::create_directory("/dev");
  if (mount("udev", "/dev", "devtmpfs", MS_NOSUID, "mode=0755,siz=10M") != 0)
    RUNTIME_ERROR("mount /dev");
  std::filesystem::create_directory("/sys");
  if (mount("sysfs", "/sys", "sysfs", MS_NOEXEC|MS_NOSUID|MS_NODEV) != 0)
    RUNTIME_ERROR("mount /sys");

  std::cout << "Determining boot partition..." << std::flush;
  auto boot_partition = determine_boot_partition();
  if (!boot_partition) {
    boot_partition = fallback_boot_partition();
  }
  if (!boot_partition) RUNTIME_ERROR("Unable to determine boot partition.");
  std::cout << boot_partition.value().path << std::endl;

  readonly_boot_partition = is_block_readonly(boot_partition.value().path);

  std::filesystem::path mnt("/mnt");
  auto mnt_boot = mnt / "boot";

  std::filesystem::create_directories(mnt_boot);
  mount_boot(boot_partition.value(), mnt_boot);
  std::cout << "Boot partition mounted." << std::endl;

  if (!readonly_boot_partition) {
    std::ofstream time_file(mnt_boot / TIME_FILE);
    time_file << time(NULL);

    preserve_previous_system_image(mnt_boot);
  }

  auto ini_path = get_ini_path(mnt_boot);
  if (ini_path && is_file(ini_path.value())) {
    ini = iniparser_load(ini_path.value().c_str());
    std::cout << ini_path.value() << " loaded." << std::endl;
  } else {
    ini = dictionary_new(0);
  }
  auto mnt_system = mnt / "system";
  std::filesystem::create_directory(mnt_system);
  mount_system(mnt_boot, mnt_system);
  std::cout << "RO Layer mouned." << std::endl;
  auto mnt_rw = mnt / "rw";
  std::filesystem::create_directory(mnt_rw);
  mount_rw(mnt_boot, mnt_rw);
  std::cout << "RW Layer mouned." << std::endl;
}

std::filesystem::path Init::get_newroot()
{
  std::filesystem::path mnt("/mnt");
  auto mnt_boot = mnt / "boot";
  auto mnt_system = mnt / "system";
  auto mnt_rw = mnt / "rw";
  auto mnt_rw_root = mnt_rw / "root";
  auto mnt_rw_work = mnt_rw / "work";
  std::filesystem::path newroot("/newroot");

  const auto& lowerdir = mnt_system, upperdir = mnt_rw_root, workdir = mnt_rw_work;

  std::cout << "Mounting overlayfs(lowerdir=" << lowerdir
    << ",upperdir=" << upperdir << ",workdir=" << workdir << ") on "
    << newroot << "..." << std::flush;
  std::filesystem::create_directory(upperdir);
  std::filesystem::create_directory(workdir);
  std::filesystem::create_directory(newroot);
  if (mount_overlay(lowerdir, upperdir, workdir, newroot) != 0) {
    RUNTIME_ERROR("mount_overlay");
  }
  //else
  std::cout << "done." << std::endl;

  auto newroot_run = newroot / "run";
  std::filesystem::create_directory(newroot_run);
  if (mount("tmpfs", newroot_run, "tmpfs", MS_NODEV|MS_NOSUID|MS_STRICTATIME, "mode=755") != 0) {
    RUNTIME_ERROR("mount tmpfs on NEWROOT/run");
  }
  //else
  std::cout << "Moving mountpoints..." << std::flush;
  auto newroot_boot = newroot_run / "initramfs/boot";
  std::filesystem::create_directories(newroot_boot);
  if (move_mount(mnt_boot, newroot_boot) != 0) {
    RUNTIME_ERROR("move_mount MNT/boot to NEWROOT/run/initramfs/boot");
  }
  //else
  auto newroot_ro = newroot_run / "initramfs/ro";
  std::filesystem::create_directory(newroot_ro);
  if (move_mount(mnt_system, newroot_ro) != 0) {
    RUNTIME_ERROR("move_mount MNT/system to NEWROOT/run/initramfs/ro");
  }
  //else
  auto newroot_rw = newroot_run / "initramfs/rw";
  std::filesystem::create_directory(newroot_rw);
  if (move_mount(mnt_rw, newroot_rw) != 0) {
    RUNTIME_ERROR("move_mount MNT/rw to NEWROOT/run/initramfs/rw");
  }
  //else
  std::cout << "done." << std::endl;

  setup_hostname(newroot);
  setup_password(newroot);
  setup_timezone(newroot);
  setup_locale(newroot);
  setup_keymap(newroot);
  setup_network(newroot);
  setup_wifi(newroot);
  setup_wireguard(newroot);
  setup_openvpn(newroot);
  setup_ssh_key(newroot);

  setup_initramfs_shutdown(newroot);

  return newroot;
}

std::optional<Partition> Init::determine_boot_partition(int max_retry/*=3*/)
{
  const char *boot_partition_uuid = getenv("boot_partition_uuid");
  if (!boot_partition_uuid) RUNTIME_ERROR("boot_partition_uuid is not set");

  std::optional<Partition> boot_partition = std::nullopt;
  for (int i = 0; i <= max_retry && !boot_partition; i++) {
    if (i > 0) sleep(i);
    boot_partition = search_partition("UUID", boot_partition_uuid);
  }
  return boot_partition;
}

std::optional<Partition> Init::fallback_boot_partition()
{
  return std::nullopt;
}

void Init::mount_boot(const Partition& boot_partition, const std::filesystem::path& mountpoint)
{
  if (mount(boot_partition.path, mountpoint) != 0)
    RUNTIME_ERROR("mount boot_partition");
}

bool Init::preserve_previous_system_image(const std::filesystem::path& boot)
{
  auto previous_image = boot / "system.cur";
  if (is_file(previous_image)) {
    if (::rename(previous_image, boot / "system.old") == 0) {
      printf("Previous system image preserved.\n");
      return true;
    }
  }
  return false;
}

std::optional<std::filesystem::path> Init::get_ini_path(const std::filesystem::path& boot)
{
  return boot / "system.ini";
}

void Init::mount_system(const std::filesystem::path& boot, const std::filesystem::path& mountpoint)
{
  if (mount_loop(boot / "system.img", mountpoint, "auto", MS_RDONLY) != 0)
    RUNTIME_ERROR("mount system_image");
}

void Init::mount_transient_rw_layer(const std::filesystem::path& mountpoint)
{
  if (mount("tmpfs", mountpoint, "tmpfs", MS_RELATIME) != 0)
    RUNTIME_ERROR("mount rw");
}

void Init::mount_rw(const std::filesystem::path& boot, const std::filesystem::path& mountpoint)
{
  mount_transient_rw_layer(mountpoint);
}

void Init::setup_initramfs_shutdown(const std::filesystem::path& newroot)
{}

void Shutdown::cleanup()
{
  std::filesystem::path mnt("/mnt"), oldroot("/oldroot");
  auto oldroot_run = oldroot / "run";

  std::filesystem::create_directory(mnt);
  if (move_mount(oldroot_run, mnt) != 0) return; // nothing further can be done
  std::cout << "Unmounting filesystems..." << std::flush;

  umount_recursive(oldroot);
  auto mnt_initramfs = mnt / "initramfs";
  umount_recursive(mnt_initramfs / "ro");
  umount_recursive(mnt_initramfs / "rw");
  auto mnt_initramfs_boot = mnt_initramfs / "boot";
  unlink(mnt_initramfs_boot / TIME_FILE);
  std::optional<std::string> boot_partition_to_be_repaired = std::nullopt;
  if (std::filesystem::exists(mnt_initramfs / "repair-boot")) {
    boot_partition_to_be_repaired = get_source_device_from_mountpoint(mnt_initramfs_boot);
  }
  umount_recursive(mnt);
  std::cout << "done." << std::endl;
  if (boot_partition_to_be_repaired) {
    std::cout << "Repairing boot partition(" << boot_partition_to_be_repaired.value() << ")..." << std::endl;
    repair_fat(boot_partition_to_be_repaired.value());
  }
}

std::string Init::ini_string(const std::string& key, const std::string& def)
{
  char buf[def.length() + 1];
  strcpy(buf, def.c_str());
  return iniparser_getstring(ini, key.c_str(), buf);
}

std::optional<std::string> Init::ini_string(const std::string& key)
{
  auto rst = iniparser_getstring(ini, key.c_str(), NULL);
  return rst? std::optional(rst) : std::nullopt;
}

int Init::ini_int(const std::string& key, int def)
{
  return iniparser_getint(ini, key.c_str(), def);
}

bool Init::ini_bool(const std::string& key, bool def)
{
  return iniparser_getboolean(ini, key.c_str(), def? 1 : 0) != 0;
}

bool Init::ini_exists(const std::string& key)
{
  return iniparser_find_entry(ini, key.c_str());
}


void Init::setup_hostname(const std::filesystem::path& newroot)
{
  auto hostname = ini_string(":hostname");
  if (!hostname) return;
  //else
  if (set_hostname(newroot, hostname.value()) == 0) {
    std::cout << "hostname: " << hostname.value() << std::endl;
    return;
  } else {
    std::cout << "Hostname setup failed." << std::endl;
  }

  if (!is_file(newroot / "run/initramfs/rw/root/etc/hostname")) {
    auto hostname = generate_default_hostname();
    if (set_hostname(newroot, hostname) == 0) {
      std::cout << "hostname(generated): " << hostname << std::endl;
    } else {
      std::cout << "Hostname setup(generated) failed." << std::endl;
    }
  }
}

void Init::setup_password(const std::filesystem::path& newroot)
{
  auto password = ini_string(":password");
  if (!password) return;
  // else
  if (set_root_password(newroot, password.value()) == 0) {
    std::cout << "Root password configured." << std::endl;
  } else {
    std::cout << "Failed to set root password." << std::endl;
  }
}

void Init::setup_timezone(const std::filesystem::path& newroot)
{}
void Init::setup_locale(const std::filesystem::path& newroot)
{}
void Init::setup_keymap(const std::filesystem::path& newroot)
{}
void Init::setup_network(const std::filesystem::path& newroot)
{}
void Init::setup_wifi(const std::filesystem::path& newroot)
{}
void Init::setup_wireguard(const std::filesystem::path& newroot)
{}
void Init::setup_openvpn(const std::filesystem::path& newroot)
{}
void Init::setup_ssh_key(const std::filesystem::path& newroot)
{}

void init();
void shutdown();

int main(int argc, char* argv[])
{
  if (strcmp(argv[0], "/init") == 0) {
    try {
      init();
    }
    catch (const std::exception& e) {
      std::cout << e.what() << std::endl;
    }
    reboot(RB_HALT_SYSTEM);
  }
  //else
  if (strcmp(argv[0], "/shutdown") != 0) {
    printf("Not a valid program name.\n");
    reboot(RB_HALT_SYSTEM);
  }
  //else
  try {
    shutdown();
  }
  catch (const std::exception& e) {
    std::cout << e.what() << std::endl;
  }

  if (strcmp(argv[1], "poweroff") == 0) {
    reboot(RB_POWER_OFF);
  } else if (strcmp(argv[1], "reboot") == 0) {
    reboot(RB_AUTOBOOT);
  } else {
    reboot(RB_HALT_SYSTEM);
  }
  return 0;
}
