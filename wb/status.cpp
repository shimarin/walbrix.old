#include <sys/utsname.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <net/if.h>  
#include <arpa/inet.h>

#include <ctype.h>
#include <iostream>
#include <fstream>
#include <optional>
#include <thread>

#include "wbc.h"
#include "status.h"

Status::Status(UIContext& _uicontext): uicontext(_uicontext),
    width(uicontext.width - uicontext.mainmenu_width), 
    height(uicontext.height - uicontext.header_height - uicontext.footer_height)
{
}

void Status::draw()
{
    if (!content) return;
    //else
    SDL_Rect rect = { uicontext.mainmenu_width, uicontext.header_height, width, height };
    //std::cout << rect.x << rect.y << rect.w << rect.h << std::endl;
    SDL_RenderCopy(uicontext, content.get(), NULL, &rect);
}

static std::optional<std::string> get_interface_name_with_default_gateway()
{
    std::ifstream routes("/proc/net/route");
    if (!routes) return std::nullopt;
    std::string line;
    if (!std::getline(routes, line)) return std::nullopt;// skip header
    while (std::getline(routes, line)) {
        std::string ifname;
        auto i = line.begin();
        while (i != line.end() && !isspace(*i)) ifname += *i++;
        if (i == line.end()) continue; // no destination
        while (i != line.end() && isspace(*i)) i++; // skip space(s)
        std::string destination;
        while (i != line.end() && !isspace(*i)) destination += *i++;

        if (destination == "00000000") return ifname;
    }
    return std::nullopt; // not found
}

static std::optional<std::string> get_ipv4_address()
{
    auto ifname = get_interface_name_with_default_gateway();
    if (!ifname || ifname.value().length() >= IFNAMSIZ) return std::nullopt;
    //else
    auto s = socket(AF_INET, SOCK_DGRAM, 0);
    if (s < 0) return std::nullopt;
    struct ifreq ifr;
    memset(&ifr, 0, sizeof(ifr));
    strcpy(ifr.ifr_name, ifname.value().c_str());
    if (ioctl(s, SIOCGIFADDR, &ifr) < 0) return std::nullopt;
    return inet_ntoa(((struct sockaddr_in *)&ifr.ifr_addr)->sin_addr);
}

static std::optional<std::string> get_cpu_clock()
{
    std::ifstream cpuinfo("/proc/cpuinfo");
    if (!cpuinfo) return std::nullopt;
    std::string line;
    std::list<int> freqs;
    const char* mhz_header = "cpu MHz		: ";
    const size_t header_len = strlen(mhz_header);
    while (std::getline(cpuinfo, line)) {
        if (!line.starts_with(mhz_header)) continue;
        freqs.push_back((int)atof(line.substr(header_len).c_str()));
    }
    if (freqs.size() == 0) return std::nullopt;
    //else
    auto minmax = std::minmax_element(freqs.begin(), freqs.end());
    int min = *minmax.first;
    int max = *minmax.second;
    if (min == max) return std::to_string(min) + "MHz";
    //else
    return  std::to_string(min) + "-" + std::to_string(max) + "MHz";
}

static std::optional<std::pair<int,int> > get_memory_capacity()
{
    std::ifstream meminfo("/proc/meminfo");
    if (!meminfo) return std::nullopt;
    std::string line;
    int available = 0, total = 0;
    while (std::getline(meminfo, line)) {
        std::string column_name;
        auto i = line.begin();
        while (i != line.end() && *i != ':') column_name += *i++;
        if (i == line.end()) continue; // unexpected EOL
        i++; // skip ':'
        while (i != line.end() && isspace(*i)) i++; // skip space(s)
        std::string value, unit;
        while (i != line.end() && !isspace(*i)) value += *i++;
        while (i != line.end() && isspace(*i)) i++; // skip space(s)
        if (i != line.end()) {
            while (i != line.end()) unit += *i++;
        }
        if (column_name == "MemTotal" && unit == "kB") total = atoi(value.c_str()) / 1024; // MB
        else if (column_name == "MemAvailable" && unit == "kB") available = atoi(value.c_str()) / 1024; // MB
        if (total > 0 && available > 0) break;
    }
    if (total == 0 || available == 0) return std::nullopt;
    //else
    return std::make_pair(available, total);
}

void Status::on_select()
{
    auto font = uicontext.registry.fonts({uicontext.FONT_PROPOTIONAL, 32});
    auto panel = create_transparent_surface(width, height);
    SDL_BlitSurface(uicontext.registry.surfaces("status_panel.png"), NULL, panel.get(), NULL);
    
    auto render_item = [this,font](const std::string& left_text, const std::string& right_text, bool good = true) {
        int item_width = width - 56;
        auto left = std::shared_ptr<SDL_Surface>(TTF_RenderUTF8_Blended(font, left_text.c_str(), (SDL_Color){255, 255, 255, 255}), SDL_FreeSurface);
        auto right = std::shared_ptr<SDL_Surface>(TTF_RenderUTF8_Blended(font, right_text.c_str(), good? (SDL_Color){94, 223, 255, 255} : (SDL_Color){255, 103, 121, 255}), SDL_FreeSurface);
        auto item = create_transparent_surface(item_width, std::max(left->h, right->h));
        SDL_Rect rect {
            0, 0, left->w, left->h
        };
        SDL_BlitSurface(left.get(), NULL, item.get(), &rect);
        rect.x = item_width - right->w;
        rect.w = right->w;
        rect.h = right->h;
        SDL_BlitSurface(right.get(), NULL, item.get(), &rect);
        return item;
    };

    struct utsname u;
    if (uname(&u) < 0) throw std::runtime_error("uname(2) failed");

    auto text = render_item("シリアルナンバー", u.nodename);
    auto item_height = 51;
    SDL_Rect rect {
        28, 40, text->w, text->h
    };
    SDL_BlitSurface(text.get(), NULL, panel.get(), &rect);

    text = render_item("カーネルバージョン", u.release);
    rect.y += item_height;
    rect.w = text->w;
    rect.h = text->h;
    SDL_BlitSurface(text.get(), NULL, panel.get(), &rect);
    
    auto ipv4_address = get_ipv4_address();
    text = render_item("IPv4アドレス", ipv4_address? ipv4_address.value() : "取得失敗", (bool)ipv4_address);
    rect.y += item_height;
    rect.w = text->w;
    rect.h = text->h;
    SDL_BlitSurface(text.get(), NULL, panel.get(), &rect);

    auto ncpu = std::thread::hardware_concurrency();
    text = render_item("論理CPUコア数", ncpu > 0? std::to_string(ncpu) : "不明", ncpu > 0);
    rect.y += item_height;
    rect.w = text->w;
    rect.h = text->h;
    SDL_BlitSurface(text.get(), NULL, panel.get(), &rect);

    auto cpu_clock = get_cpu_clock();
    text = render_item("CPUクロック", cpu_clock? cpu_clock.value() : "不明", (bool)cpu_clock);
    rect.y += item_height;
    rect.w = text->w;
    rect.h = text->h;
    SDL_BlitSurface(text.get(), NULL, panel.get(), &rect);

    bool kvm = false;
    try { kvm = std::filesystem::is_character_file("/dev/kvm"); }
    catch (const std::filesystem::filesystem_error&) { ; }
    text = render_item("仮想化命令サポート", kvm? "あり" : "なし", kvm);
    rect.y += item_height;
    rect.w = text->w;
    rect.h = text->h;
    SDL_BlitSurface(text.get(), NULL, panel.get(), &rect);

    auto memory = get_memory_capacity();
    text = render_item("メモリ(空き/合計)", memory? (std::to_string(memory.value().first) + "/" + std::to_string(memory.value().second) + "MB") :"不明", (bool)memory);
    rect.y += item_height;
    rect.w = text->w;
    rect.h = text->h;
    SDL_BlitSurface(text.get(), NULL, panel.get(), &rect);

    // 中央サーバ

    content = std::shared_ptr<SDL_Texture>(SDL_CreateTextureFromSurface(uicontext, panel.get()), SDL_DestroyTexture);
}

void Status::on_deselect()
{
    content = NULL;
}

static int _main(int,char*[])
{
    return 0;
}

#ifdef __MAIN_MODULE__
int main(int argc, char* argv[]) { return _main(argc, argv); }
#endif

