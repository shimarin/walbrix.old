#include <unistd.h>
#include <sys/stat.h>
#include <sys/sysmacros.h>

#include <filesystem>
#include <functional>
#include <set>

#include <pstream.h>
#define PICOJSON_USE_INT64
#include <picojson.h>

#include "disk.h"

static Blockdevice obj2blockdevice(picojson::object& d)
{
    Blockdevice device;
    device.name = d["name"].get<std::string>();
    device.pkname = d["pkname"].is<std::string>()? std::optional(d["pkname"].get<std::string>()) : std::nullopt;
    device.type = d["type"].get<std::string>();
    device.model = d["model"].is<std::string>()? std::optional(d["model"].get<std::string>()) : std::nullopt;
    device.ro = d["ro"].get<bool>();
    device.size = d["size"].get<int64_t>();
    device.tran = d["tran"].is<std::string>()? std::optional(d["tran"].get<std::string>()) : std::nullopt;
    device.log_sec = d["log-sec"].is<int64_t>()? std::optional(d["log-sec"].get<int64_t>()) : std::nullopt;
    device.mountpoint = d["mountpoint"].is<std::string>()? std::optional(std::filesystem::path(d["mountpoint"].get<std::string>())) : std::nullopt;

    auto maj_min = d["maj:min"].get<std::string>();
    auto colon = maj_min.find(':');
    if (colon == std::string::npos) std::runtime_error("Invalid maj:min string");
    //else
    device.maj_min = {
        std::stoi(maj_min.substr(0,colon)), 
        std::stoi(maj_min.substr(colon + 1))
    };

    return device;
}

static bool for_each_blockdevice(std::function<bool(const Blockdevice&)> func)
{
    redi::pstream in("lsblk -b -n -l -J -o NAME,MODEL,TYPE,PKNAME,RO,MOUNTPOINT,SIZE,TRAN,LOG-SEC,MAJ:MIN");
    if (in.fail()) throw std::runtime_error("Failed to execute lsblk");
    // else
    picojson::value v;
    const std::string err = picojson::parse(v, in);
    if (!err.empty()) throw std::runtime_error(err);
    //else
    for (auto& _d : v.get<picojson::object>()["blockdevices"].get<picojson::array>()) {
        if (!func(obj2blockdevice(_d.get<picojson::object>()))) return false;
    }
    return true;
};

std::vector<Disk> get_unused_disks(uint64_t least_size/* = 1024L * 1024 * 1024 * 4*/)
{
    std::map<std::string,Disk> disk_map;
    std::set<std::string> to_be_removed;
    for_each_blockdevice([&disk_map,&to_be_removed,least_size](auto device) {
        if (device.mountpoint) {
            if (device.pkname) to_be_removed.insert(device.pkname.value());
        } else if (device.type == "disk" && device.size >= least_size && device.log_sec) {
            disk_map[device.name] = device;
        }
        return true;
    });

    std::vector<Disk> disks;
    for (const auto& item : disk_map) {
        if (!to_be_removed.contains(item.first)) disks.push_back(item.second);
    }
    return disks;
}

Disk get_unused_disk(const std::filesystem::path& device_path, uint64_t least_size/* = 1024L * 1024 * 1024 * 4*/)
{
    if (!std::filesystem::exists(device_path)) throw std::runtime_error(device_path.string() + " does not exist.");
    if (!std::filesystem::is_block_file(device_path)) throw std::runtime_error(device_path.string() + " is not a block device.");
    //else
    struct stat st;
    if (stat(device_path.c_str(), &st) < 0) throw std::runtime_error("stat");

    std::optional<Blockdevice> disk_found;
    std::set<std::string> disks_have_mounted_partition;
    std::pair<int,int> maj_min = {major(st.st_rdev), minor(st.st_rdev)};
    for_each_blockdevice([&maj_min,&disk_found,&disks_have_mounted_partition](auto device) {
        if (device.mountpoint) {
            if (device.pkname) disks_have_mounted_partition.insert(device.pkname.value());
        } else if (device.maj_min == maj_min && device.type == "disk") {
            disk_found = device;
        }
        return true;
    });

    if (!disk_found) throw std::runtime_error(device_path.string() + " is not a disk.");
    //else
    const auto disk = disk_found.value();
    if (disk.size < least_size) throw std::runtime_error(device_path.string() + " has no sufficient capacity.");
    //else
    if (!disk.log_sec) throw std::runtime_error(std::string("Cannot determine logical block size of ") + device_path.string() + ".");
    //else
    if (disks_have_mounted_partition.contains(disk.name)) {
        throw std::runtime_error(device_path.string() + " has mounted partition.");
    }

    return disk;
}

static int _main(int,char*[])
{
    auto disks = get_unused_disks(0);
    for (const auto& disk : disks) {
        std::cout << disk.name << " maj=" << disk.maj_min.first << ", min=" << disk.maj_min.second << std::endl;
    }

    auto disk = get_unused_disk("/dev/nvme0n1", 1024L * 1024 * 1024 * 4);
    std::cout << disk.name << " maj=" << disk.maj_min.first << ", min=" << disk.maj_min.second << std::endl;
    return 0;
}

#ifdef __MAIN_MODULE__
int main(int argc, char* argv[]) { return _main(argc, argv); }
#endif
