#include <optional>
#include <filesystem>
#include <regex>
#include <sys/reboot.h>
#include <sys/mount.h>

#include <iniparser4/iniparser.h>

#define RUNTIME_ERROR(msg) throw std::runtime_error((std::string)__FILE__ + '(' + std::to_string(__LINE__) + ") " + msg)
#define RUNTIME_ERROR_WITH_ERRNO(msg) throw std::runtime_error((std::string)__FILE__ + '(' + std::to_string(__LINE__) + ") " + msg + ':' + strerror(errno))

struct Partition {
  std::filesystem::path path;
  std::optional<std::string> fstype;
};

std::optional<Partition> search_partition(const std::string& name, const std::string& value);
bool is_block_readonly(const std::filesystem::path& device_path);
bool is_file(const std::filesystem::path& path);
bool is_dir(const std::filesystem::path& path);
bool is_block(const std::filesystem::path& path);
int cp_a(const std::filesystem::path& src, const std::filesystem::path& dst);
int cp_au(const std::filesystem::path& src, const std::filesystem::path& dst);
int unlink(const std::filesystem::path& path);
int create_whiteout(const std::filesystem::path& path);

int mount(const std::filesystem::path& source,
  const std::filesystem::path& mountpoint,
  const std::string& fstype = "auto", unsigned int mountflags = MS_RELATIME,
  const std::string& data = "");
int mount_loop(std::filesystem::path source, std::filesystem::path mountpoint,
  const std::string& fstype = "auto", unsigned int mountflags = MS_RELATIME,
  const std::string& data = "", int offset = 0);
int umount(const std::filesystem::path& mountpoint);
int bind_mount(std::filesystem::path source, std::filesystem::path mountpoint);
int repair_fat(const std::filesystem::path& path);
uint64_t get_free_disk_space(const std::filesystem::path& mountpoint);
int create_btrfs_imagefile(const std::filesystem::path& imagefile, off_t length);
int enable_lvm();
int btrfs_scan();
int repair_btrfs(const std::filesystem::path& path);
int create_swapfile(const std::filesystem::path& swapfile, off_t length);
int swapon(const std::filesystem::path& swapfile, bool mkswap_and_retry_on_fail = true);

int set_hostname(const std::filesystem::path& rootdir, const std::string& hostname);
std::string generate_default_hostname(const std::string& prefix = "host");

class Init {
  bool readonly_boot_partition = 0;
  dictionary* ini;
protected:
  void mount_transient_rw_layer(const std::filesystem::path& mountpoint);

  virtual std::optional<Partition> determine_boot_partition(int max_retry = 3);
  virtual std::optional<Partition> fallback_boot_partition();
  virtual void mount_boot(const Partition& boot_partition, const std::filesystem::path& mountpoint);
  virtual bool preserve_previous_system_image(const std::filesystem::path& boot);
  virtual std::optional<std::filesystem::path> get_ini_path(const std::filesystem::path& boot);
  virtual void mount_system(const std::filesystem::path& boot, const std::filesystem::path& mountpoint);
  virtual void mount_rw(const std::filesystem::path& boot, const std::filesystem::path& mountpoint);
  virtual bool activate_swap(const std::filesystem::path& boot);

  virtual std::filesystem::path get_upperdir(const std::filesystem::path& rw_layer);
  virtual std::filesystem::path get_workdir(const std::filesystem::path& rw_layer);

  virtual std::pair<std::string,int> get_default_network_interface_name();

  virtual void setup_initramfs_shutdown(const std::filesystem::path& newroot);

  virtual void setup_hostname(const std::filesystem::path& newroot);
  virtual void setup_network(const std::filesystem::path& newroot);
  virtual void setup_password(const std::filesystem::path& newroot);
  virtual void setup_timezone(const std::filesystem::path& newroot);
  virtual void setup_locale(const std::filesystem::path& newroot);
  virtual void setup_keymap(const std::filesystem::path& newroot);
  virtual void setup_wifi(const std::filesystem::path& newroot);
  virtual void setup_wireguard(const std::filesystem::path& newroot);
  virtual void setup_openvpn(const std::filesystem::path& newroot);
  virtual void setup_zabbix_agent(const std::filesystem::path& newroot);
  virtual void setup_ssh_key(const std::filesystem::path& newroot);
  virtual void setup_zram_swap(const std::filesystem::path& newroot);
  virtual void invalidate_ld_cache(const std::filesystem::path& newroot);

public:
  Init();
  virtual ~Init();

  bool is_boot_partition_readonly() { return readonly_boot_partition; }
  virtual void setup();
  virtual std::filesystem::path get_newroot();

  std::string ini_string(const std::string& key, const std::string& def);
  std::optional<std::string> ini_string(const std::string& key);
  int ini_int(const std::string& key, int def);
  bool ini_bool(const std::string& key, bool def);
  bool ini_exists(const std::string& key);
};

class Shutdown {
public:
  virtual void cleanup();
};
