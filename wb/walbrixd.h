#include <filesystem>

static const std::filesystem::path WALBRIXD_CONSOLE_SOCKET_BASE_DIR("/run/walbrix/console");
static const std::filesystem::path WALBRIX_VM_ROOT("/var/vm");

#define WALBRIXD_SERVICE_NAME "com.walbrix.Walbrix"
#define WALBRIXD_OBJECT_PATH "/com/walbrix/Walbrix"
#define WALBRIXD_INTERFACE_NAME WALBRIXD_SERVICE_NAME

#define WALBRIX_XATTR_AUTOSTART "user.walbrix.autostart"

inline static void for_each_vmdir(std::function<void(const std::string& name, const std::filesystem::directory_entry&)> func)
{
    for (const std::filesystem::directory_entry& x : std::filesystem::directory_iterator(WALBRIX_VM_ROOT)) {
        if (!x.is_directory()) continue;
        //else
        auto name = x.path().filename();
        if (name.string()[0] == '@') continue;
        // else
        func(name, x);
    }
}

template <typename T> std::optional<T> with_vmdir(const std::string& name, std::function<T(const std::filesystem::directory_entry&)> func)
{
    std::filesystem::path vm_path = WALBRIX_VM_ROOT / name;
    if (!std::filesystem::exists(vm_path) || !std::filesystem::is_directory(vm_path)) return std::nullopt;
    return func(std::filesystem::directory_entry(vm_path));
}