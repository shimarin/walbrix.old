#ifndef __DISK_H__
#define __DISK_H__

#include <string>
#include <optional>
#include <filesystem>
#include <vector>

struct Disk {
    std::string name;
    std::optional<std::string> model;
    bool ro;
    uint64_t size;
    std::optional<std::string> tran;
    std::optional<uint16_t> log_sec;
    std::pair<int,int> maj_min;
};

struct Blockdevice : public Disk {
    std::optional<std::string> pkname;
    std::string type;
    std::optional<std::filesystem::path> mountpoint;
};

std::vector<Disk> get_unused_disks(uint64_t least_size = 1024L * 1024 * 1024 * 4);
Disk get_unused_disk(const std::filesystem::path& device_path, uint64_t least_size = 1024L * 1024 * 1024 * 4);

#endif // __DISK_H__
