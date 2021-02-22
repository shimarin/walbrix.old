#include <unistd.h>
#include <pty.h>
#include <sys/wait.h>
#include <sys/xattr.h>

#include <security/pam_appl.h>
#include <security/pam_misc.h>

#include <fstream>

#include <argparse/argparse.hpp>

#include "walbrixd.h"
#include "terminal.h"
#include "sdlplusplus.h"

#include "wbc.h"
#include "status.h" 
#include "shutdown.h"
#include "installer.h"

std::shared_ptr<SDL_Surface> create_transparent_surface(int w, int h)
{
    return make_shared(SDL_CreateRGBSurface(0, w, h, 32,0xff, 0xff00, 0xff0000, 0xff000000));
}

int console(const char* vmname);
int console(const std::vector<std::string>& args);

int start(const std::vector<std::string>& args)
{
    argparse::ArgumentParser program(args[0]);
    program.add_argument("--console", "-c").help("Imeddiately connect to console").default_value(false).implicit_value(true);
    program.add_argument("vmname").help("VM name");
    try {
        program.parse_args(args);
    }
    catch (const std::runtime_error& err) {
        std::cout << err.what() << std::endl;
        std::cout << program;
        return 1;
    }

    auto vmname = program.get<std::string>("vmname");
    
    auto pid = fork();
    if (pid < 0) throw std::runtime_error("fork() failed");

    if (!pid) { // child process
        execlp("busctl", "busctl", "--system", "call", 
            WALBRIXD_SERVICE_NAME, WALBRIXD_OBJECT_PATH, WALBRIXD_INTERFACE_NAME, 
            "Start", "s", vmname.c_str(), NULL
        );
    }

    //else (parent process)
    int status;
    waitpid(pid, &status, 0); // wait for child process

    if (status == 0 && program.get<bool>("--console")) {
        return console(vmname.c_str());
    }

    //else
    return WEXITSTATUS(status);
}

static int stop(const std::vector<std::string>& args)
{
    argparse::ArgumentParser program(args[0]);
    program.add_argument("vmname").help("VM name");
    try {
        program.parse_args(args);
    }
    catch (const std::runtime_error& err) {
        std::cout << err.what() << std::endl;
        std::cout << program;
        return 1;
    }
    
    auto vmname = program.get<std::string>("vmname");
    
    execlp("busctl", "busctl", "--system", "call", 
        WALBRIXD_SERVICE_NAME, WALBRIXD_OBJECT_PATH, WALBRIXD_INTERFACE_NAME, 
        "Stop", "s", vmname.c_str(), NULL
    );

    return 0;
}

static int list(const std::vector<std::string>& args)
{
    execlp("busctl", "busctl", "--system", "call", 
        WALBRIXD_SERVICE_NAME, WALBRIXD_OBJECT_PATH, WALBRIXD_INTERFACE_NAME, 
        "List", NULL
    );

    return 0;
}

int autostart(const std::vector<std::string>& args)
{
    argparse::ArgumentParser program(args[0]);
    program.add_argument("vmname").help("VM name");
    program.add_argument("action").help("'on' or 'off'").default_value(std::string("show"));
    try {
        program.parse_args(args);
    }
    catch (const std::runtime_error& err) {
        std::cout << err.what() << std::endl;
        std::cout << program;
        return 1;
    }

    auto vmname = program.get<std::string>("vmname");
    auto action = program.get<std::string>("action");

    auto rst = with_vmdir<int>(vmname, [&action](auto vmdir) {
        if (action == "show") {
            char c;
            bool on = (getxattr(vmdir.path().c_str(), WALBRIX_XATTR_AUTOSTART, &c, sizeof(c)) >= 0);
            std::cout << "autostart is " << (on? "on" : "off") << std::endl;
        } else if (action == "on") {
            if (setxattr(vmdir.path().c_str(), WALBRIX_XATTR_AUTOSTART, "", 0, 0) < 0)
                throw std::runtime_error(strerror(errno));
        } else if (action == "off") {
            if (removexattr(vmdir.path().c_str(), WALBRIX_XATTR_AUTOSTART) < 0 && errno != ENODATA)
                throw std::runtime_error(strerror(errno));
        } else {
            std::cerr << "Invalid action specified." << std::endl;
            return -1;
        }
        return 0;
    });

    if (!rst) {
        std::cerr << "VM not found." << std::endl;
        return -1;
    }
    //else
    return rst.value();
}

bool auth(UIContext& uicontext)
{
    bool rst = true;

    auto font_def = std::make_pair(uicontext.FONT_PROPOTIONAL, 40);
    auto font = uicontext.registry.fonts(font_def);

    struct Env {
        UIContext& uicontext;
        TTF_Font* font;
        int result = 0;
        bool cancelled = false;
    } env = {
        uicontext, font
    };
    struct pam_conv conv = {
        [](int num_msg, const struct pam_message** msg, struct pam_response** resp, void* appdata_ptr) {
            Env& env = *((Env*)appdata_ptr);
            struct pam_response *aresp;
            if (num_msg <= 0 || num_msg > PAM_MAX_NUM_MSG) return PAM_CONV_ERR;
            if ((aresp = (pam_response*)calloc(num_msg, sizeof *aresp)) == NULL) return PAM_BUF_ERR;

            for (int i = 0; i < num_msg; i++) {
                aresp[i].resp_retcode = 0;
                if (msg[i]->msg_style == PAM_PROMPT_ECHO_OFF || msg[i]->msg_style == PAM_PROMPT_ECHO_ON) {
                    std::string password;
                    struct TextureAndRect {
                        SDL_Texture* texture = NULL;
                        SDL_Rect rect;
                        void operator()() { if (texture) SDL_DestroyTexture(texture); texture = NULL; }
                        ~TextureAndRect() { (*this)(); }
                        operator bool() { return (texture != NULL); }
                        const TextureAndRect& operator()(SDL_Renderer* renderer,SDL_Surface* surface) {
                            if (texture) SDL_DestroyTexture(texture);
                            texture = SDL_CreateTextureFromSurface(renderer, surface);
                            rect.w = surface->w;
                            rect.h = surface->h;
                            return *this;
                        }
                        const SDL_Rect& operator()(int x, int y) { rect.x = x; rect.y = y; return rect; }
                        int operator()(SDL_Renderer* renderer) { if (texture) return SDL_RenderCopy(renderer, texture, NULL, &rect); else return -1; }
                    } password_texture, message_texture;
                    while (true) {
                        env.uicontext.render();
                        if (!password_texture) {
                            std::string message(msg[i]->msg);
                            message += ' ';
                            for (int i = 0; i < password.length(); i++) message += '*';
                            auto surface = TTF_RenderUTF8_Blended(env.font, message.c_str(), (SDL_Color){0, 0, 0, 0});
                            password_texture(env.uicontext.renderer, surface);
                            password_texture(0, env.uicontext.height * 3 / 5);
                            SDL_FreeSurface(surface);
                        }
                        password_texture(env.uicontext.renderer);

                        if (!process_event([&env,&password,&password_texture](auto ev) {
                            if (ev.type == SDL_TEXTINPUT) {
                                for (int i = 0; i < strlen(ev.text.text); i++) {
                                    if (password.length() < 32) password += (char)ev.text.text[i];
                                }
                                if (password_texture) password_texture();
                            } else if (ev.type == SDL_KEYDOWN) {
                                if (ev.key.keysym.sym == SDLK_RETURN || ev.key.keysym.sym == SDLK_KP_ENTER) {
                                    SDL_RenderPresent(env.uicontext.renderer);
                                    return false;
                                } else if (ev.key.keysym.sym == SDLK_BACKSPACE) {
                                    if (password.length() > 0) {
                                        password.pop_back();
                                        if (password_texture) password_texture();
                                    }
                                } else if (ev.key.keysym.sym == SDLK_ESCAPE) {
                                    env.cancelled = true;
                                    SDL_RenderPresent(env.uicontext.renderer);
                                    return false;
                                }
                            }
                            return true;
                        })) break;

                        if (env.result == PAM_PERM_DENIED && !message_texture) {
                            auto surface = TTF_RenderUTF8_Blended(env.font, "パスワードが正しくありません", (SDL_Color){255, 0, 0, 0});
                            message_texture(env.uicontext.renderer, surface);
                            message_texture(0, password_texture.rect.y + password_texture.rect.h);
                            SDL_FreeSurface(surface);
                        }
                        message_texture(env.uicontext.renderer);

                        auto caret_rect = (SDL_Rect){password_texture.rect.w, password_texture.rect.y, 4, password_texture.rect.h};
                        Uint8 alpha = std::abs(std::sin((SDL_GetTicks() % 2000 * pi * 2 / 2000))) * 255;
                        SDL_SetRenderDrawColor(env.uicontext.renderer, 0, 0, 0, alpha);
                        SDL_SetRenderDrawBlendMode(env.uicontext.renderer, SDL_BLENDMODE_BLEND);
                        SDL_RenderFillRect(env.uicontext.renderer, &caret_rect);
                        SDL_RenderPresent(env.uicontext.renderer);
                    }
                    aresp[i].resp = strdup(password.c_str());
                }
            }
            *resp = aresp;
            return PAM_SUCCESS;
        },
        &env
    };
    pam_handle_t *pamh;
    pam_start("login", "root", &conv, &pamh);
    do {
        env.result = pam_authenticate(pamh, 0);
    } while (env.result != PAM_SUCCESS && env.result != PAM_ABORT && env.result != PAM_MAXTRIES && !env.cancelled);
    pam_end(pamh, env.result);

    uicontext.registry.fonts.discard(font_def);

    return (env.result != PAM_ABORT && env.result != PAM_MAXTRIES && !env.cancelled);
}

bool title(UIContext& uicontext)
{
    auto title_background = std::get<0>(uicontext.create_texture_from_transient_surface("title_background.png"));
    auto title = uicontext.create_texture_from_transient_surface("title.png");
    SDL_Rect title_rect = { (uicontext.width - std::get<1>(title)) / 2, uicontext.height * 1 / 3, std::get<1>(title), std::get<2>(title) };

    auto font = std::make_pair(uicontext.FONT_PROPOTIONAL, 48);

    auto title_message = uicontext.render_font_as_texture(font, "開始するにはEnterを押してください", {255, 255, 255, 255});
    SDL_Rect title_message_rect = { (uicontext.width - std::get<1>(title_message)) / 2, uicontext.height * 3 / 4, std::get<1>(title_message), std::get<2>(title_message) };

    auto copyright = uicontext.render_font_as_texture(font, "Copyright© 2009-2021 Walbrix Corporation", {0, 0, 0, 0});
    SDL_Rect copyright_rect = { (uicontext.width - std::get<1>(copyright)) / 2, uicontext.height - std::get<2>(copyright) - 20, std::get<1>(copyright), std::get<2>(copyright) };
    uicontext.registry.fonts.discard(font);

    uicontext.push_render_func(
        [title_background,title,title_rect,copyright,copyright_rect](SDL_Renderer* renderer, bool) {
            SDL_RenderCopy(renderer, title_background.get(), NULL, NULL);
            SDL_RenderCopy(renderer, std::get<0>(title).get(), NULL, &title_rect);
            SDL_RenderCopy(renderer, std::get<0>(copyright).get(), NULL, &copyright_rect);
            return true;            
        }
    );

    uicontext.push_render_func(
        [&title_message,&title_message_rect](SDL_Renderer* renderer,bool) {
            Uint8 alpha = std::abs(std::sin((SDL_GetTicks() % 4000 * pi * 2 / 4000))) * 255;
            SDL_SetTextureAlphaMod(std::get<0>(title_message).get(), alpha);
            SDL_RenderCopy(renderer, std::get<0>(title_message).get(), NULL, &title_message_rect);
            return true;
        }
    );

    while (process_event([](auto ev) { return !(ev.type == SDL_KEYDOWN && ev.key.keysym.sym == SDLK_RETURN); })) {
        uicontext.render();
        SDL_RenderPresent(uicontext.renderer);
    }

    uicontext.pop_render_func();
    bool rst = auth(uicontext);

    uicontext.pop_render_func();
    return rst;
}

int local_console(UIContext& uicontext, const char* prog, const std::vector<std::string>& args = {})
{
    const int rows = 32, cols = 80;

    int fd;
    struct winsize win = { (unsigned short)rows, (unsigned short)cols, 0, 0 };
    auto pid = forkpty(&fd, NULL, NULL, &win);
    if (pid < 0) throw std::runtime_error("forkpty failed");
    //else
    if (!pid) {
        signal(SIGTERM, SIG_DFL);
        signal(SIGINT, SIG_DFL);
        setenv("TERM", "xterm-256color", 1);
        setenv("LANG", "ja_JP.utf8", 1);
        char ** argv = new char *[args.size() + 2];
        argv[0] = strdup(prog);
        for (int i = 1; i <= args.size(); i++) {
            argv[i] = strdup(args[i - 1].c_str());
        }
        argv[args.size() + 1] = NULL;
        if (execvp(prog, argv) < 0) exit(-1);
    }
    //else 

    struct AutoClose {
        int fd;
        AutoClose(int _fd) : fd(_fd) {;}
        ~AutoClose() { close(fd); }
    } autoclose_fd(fd);

    auto font = uicontext.registry.fonts({uicontext.FONT_FIXED, 16});
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

        process_event([&terminal](auto ev) { terminal.processEvent(ev); return true; });
        if (!terminal.processInput()) break; // EOF detected

        SDL_RenderPresent(uicontext.renderer);
    }
    uicontext.pop_render_func();

    return status;
}

void fallback_to_agetty(const char* tty, bool autologin = false)
{
    if (autologin) {
        execl("/sbin/agetty", "/sbin/agetty", "-o", "-p -- \\u", "--autologin", "root", "--noclear", tty, getenv("TERM"), NULL);
    }
    //else
    execl("/sbin/agetty", "/sbin/agetty", "-o", "-p -- \\u", "--noclear", tty, getenv("TERM"), NULL);
}

void ui(UIContext& uicontext)
{
    if (uicontext.tty && !uicontext.installer) {
        while (!title(uicontext)) { ; }
    }

    auto background = std::get<0>(uicontext.create_texture_from_transient_surface("background.png"));

    auto header = uicontext.create_texture_from_transient_surface("header.png");
    uicontext.header_height = std::get<2>(header);

    auto header_logo = uicontext.create_texture_from_transient_surface("header_logo.png");

    auto footer = uicontext.create_texture_from_transient_surface("footer.png");
    uicontext.footer_height = std::get<2>(footer);

    auto mainmenu_panel = uicontext.create_texture_from_transient_surface("mainmenu_panel.png");
    uicontext.mainmenu_width = std::get<1>(mainmenu_panel);

    auto create_mainmenu_item_texture = [&uicontext](const char* icon_name, const char* text) {
        auto font = uicontext.registry.fonts({uicontext.FONT_PROPOTIONAL, 32});
        auto icon = uicontext.registry.surfaces.transient(icon_name);
        auto surface0 = std::shared_ptr<SDL_Surface>(SDL_CreateRGBSurface(0, uicontext.mainmenu_width, uicontext.mainmenu_item_height, 32,0xff, 0xff00, 0xff0000, 0xff000000), SDL_FreeSurface);
        auto surface1 = std::shared_ptr<SDL_Surface>(TTF_RenderUTF8_Blended(font, text, {0, 0, 0, 0}), SDL_FreeSurface);
        //auto surface2 = std::shared_ptr<SDL_Surface>(TTF_RenderUTF8_Blended(font, text, {255, 255, 255, 255}), SDL_FreeSurface);
        {
            SDL_Rect rect = { (uicontext.mainmenu_item_height - icon->w) / 2, (surface0->h - icon->h) / 2, icon->w, icon->h };
            SDL_BlitSurface(icon.get(), NULL, surface0.get(), &rect);
        }
        SDL_Rect rect = { uicontext.mainmenu_item_height, (surface0->h - surface1->h) / 2, surface1->w, surface1->h };
        SDL_BlitSurface(surface1.get(), NULL, surface0.get(), &rect);
        //rect.x += 2;
        //rect.y += 2;
        //SDL_BlitSurface(surface2.get(), NULL, surface0.get(), &rect);
        return std::shared_ptr<SDL_Texture>(SDL_CreateTextureFromSurface(uicontext.renderer, surface0.get()), SDL_DestroyTexture);
    };

    Status status(uicontext);
    Shutdown shutdown(uicontext);
    Installer installer(uicontext);

    struct MainMenuItem {
        std::string name;
        int y;
        std::shared_ptr<SDL_Texture> texture;
        std::function<void()> draw;
        std::function<void()> on_select;
        std::function<void()> on_deselect;
        std::function<bool()> on_enter;
    };

    std::vector<MainMenuItem> menuitems;

    int y = uicontext.mainmenu_item_height;
    if (uicontext.installer) {
        menuitems.push_back({"install", y, create_mainmenu_item_texture("icon_install.png", "インストール"), 
            [&installer](){installer.draw();},[&installer](){installer.on_select();}, [&installer](){installer.on_deselect();}, [&installer](){return installer.on_enter();} });
        y += uicontext.mainmenu_item_height;
    }
    menuitems.push_back({"status", y, create_mainmenu_item_texture("icon_status.png", "情報"), 
        [&status](){status.draw();},[&status]() {status.on_select();}, [&status](){status.on_deselect();}, NULL });
    y += uicontext.mainmenu_item_height;
    menuitems.push_back({"console", y, create_mainmenu_item_texture("icon_console.png", "Linuxコンソール"), [](){},[]() {}, [](){}, [&uicontext](){
        if (uicontext.tty && geteuid() == 0) {
            local_console(uicontext, "/bin/login", {"-p", "-f", "root"});
        } else {
            local_console(uicontext, "bash");
        }
        return true; // continue with main menu
    } });
    y = 580;
    if (uicontext.tty) {
        menuitems.push_back({"shutdown", y, create_mainmenu_item_texture("icon_shutdown.png", "シャットダウン"),
        [&shutdown](){shutdown.draw();},[&shutdown]() {shutdown.on_select();}, [&shutdown](){shutdown.on_deselect();}, [&shutdown](){return shutdown.on_enter();}});
        y += uicontext.mainmenu_item_height;
    }
    if (!(uicontext.tty) || !uicontext.installer) {
        menuitems.push_back({"back", y, create_mainmenu_item_texture("icon_back.png", uicontext.tty? "タイトルへ戻る" : "終了"), 
            [](){},[]() {}, [](){}, [](){return false;}});
    }

    auto cursor1 = std::get<0>(uicontext.create_texture_from_transient_surface("mainmenu_cursor1.png"));
    auto cursor2 = std::get<0>(uicontext.create_texture_from_transient_surface("mainmenu_cursor2.png"));

    int selected = 0;
    menuitems[selected].on_select();

    uicontext.push_render_func([&uicontext,&background,&header,&header_logo,&footer,&mainmenu_panel,
        &menuitems,&cursor1,&cursor2,&selected](auto renderer, bool focus) {
        SDL_RenderCopy(renderer, background.get(), NULL, NULL);
        SDL_Rect header_rect = { 0, 0, std::get<1>(header), uicontext.header_height };
        SDL_RenderCopy(renderer, std::get<0>(header).get(), NULL, &header_rect);
        SDL_Rect header_logo_rect = { 0, 0, std::get<1>(header_logo), std::get<2>(header_logo) };
        SDL_RenderCopy(renderer, std::get<0>(header_logo).get(), NULL, &header_logo_rect);
        SDL_Rect footer_rect = { 0, uicontext.height - std::get<2>(footer), std::get<1>(footer), uicontext.footer_height };
        SDL_RenderCopy(renderer, std::get<0>(footer).get(), NULL, &footer_rect);
        SDL_Rect mainmenu_panel_rect = { 0, header_rect.h, uicontext.mainmenu_width, std::get<2>(mainmenu_panel) };
        SDL_RenderCopy(renderer, std::get<0>(mainmenu_panel).get(), NULL, &mainmenu_panel_rect);

        SDL_Rect rect = {0, uicontext.header_height, uicontext.mainmenu_width, uicontext.mainmenu_item_height};
        for (auto i = menuitems.begin(); i != menuitems.end(); i++) {
            rect.y = i->y;
            if (selected == std::distance(menuitems.begin(), i)) {
                auto cursor = (focus && i->on_enter)? cursor1.get() : cursor2.get();
                if (focus) {
                    Uint8 alpha = std::abs(std::sin((SDL_GetTicks() % 4000 * pi * 2 / 4000))) * 127 + 128;
                    SDL_SetTextureAlphaMod(cursor, alpha);
                }
                SDL_RenderCopy(renderer, cursor, NULL, &rect);
            }
            SDL_RenderCopy(renderer, i->texture.get(), NULL, &rect);
        }

        return true;
    });

    while (true) {
        uicontext.render();
        menuitems[selected].draw();
    
        if (!process_event([&uicontext,&menuitems,&selected](auto ev) {
            if (ev.type == SDL_KEYDOWN) {
                if (ev.key.keysym.sym == SDLK_UP && selected > 0) {
                    if (menuitems[selected].on_deselect) menuitems[selected].on_deselect();
                    selected -= 1;
                    if (menuitems[selected].on_select) menuitems[selected].on_select();
                } else if (ev.key.keysym.sym == SDLK_DOWN && selected < menuitems.size() - 1) {
                    if (menuitems[selected].on_deselect) menuitems[selected].on_deselect();
                    selected += 1;
                    if (menuitems[selected].on_select) menuitems[selected].on_select();
                } else if ((ev.key.keysym.sym == SDLK_RETURN || ev.key.keysym.sym == SDLK_KP_ENTER) && menuitems[selected].on_enter) {
                    if (!menuitems[selected].on_enter()) return false;
                }
            }
            return true;
        })) break;
        SDL_RenderPresent(uicontext.renderer);
    }


    uicontext.pop_render_func();
}

int ui(const char* tty = NULL, bool installer = false)
{
    std::fstream ftty (std::filesystem::path("/dev") / (tty? tty : "null"), std::ios::in | std::ios::out);
    std::ostream& cout = (tty && ftty)? ftty : std::cout;
    std::ostream& cerr = (tty && ftty)? ftty : std::cerr;

    if (installer && geteuid() != 0) {
        cout << "Warning: Running installer without root privilege." << std::endl;
    }

    const int width = 1024, height = 768;

    std::filesystem::path theme_dir1("/usr/share/wb/themes/default");
    std::filesystem::path theme_dir2("./default_theme");

    const auto& theme_dir = std::filesystem::exists(theme_dir1)? theme_dir1 : theme_dir2;

    // wait for graphics hardware drivers to be loaded(hopefully)
    system("udevadm settle");

    int rst = 0;
    std::optional<std::string> error_message;

    try {
        if (SDL_Init(SDL_INIT_VIDEO) < 0) throw UnrecoverableSDLError("SDL_Init");
        if (TTF_Init() < 0) throw TTFError();
        auto window = make_shared(SDL_CreateWindow("walbrix",SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,width,height,SDL_WINDOW_SHOWN));
        if (!window) throw UnrecoverableSDLError("SDL_CreateWindow");
        auto renderer = make_shared(SDL_CreateRenderer(window.get(), -1, SDL_RENDERER_PRESENTVSYNC));
        if (!renderer) throw UnrecoverableSDLError("SDL_CreateRenderer");
        UIContext uicontext(renderer.get(), theme_dir, tty, installer);
        ui(uicontext);
    }
    catch (const UnrecoverableSDLError& e) {
        std::string what = e.what();
        if ((what == "SDL_Init" || what == "SDL_CreateWindow" || what == "SDL_CreateRenderer") && tty) {
            rst = 114516;
        } else {
            error_message = std::string(e.what()) + ": " + SDL_GetError();
            rst = 1;
        }
    }
    catch (const Terminated& e) {
        rst = 1;
    }
    catch (const PerformShutdown& e) {
        rst = 114514;
    }
    catch (const PerformReboot& e) {
        rst = 114515;
    }
    catch (const TTFError& e) {
        rst = 1;
    }
    catch (const std::exception& e) {
        error_message = e.what();
        rst = 1;
    }

    if (TTF_WasInit()) TTF_Quit();
    SDL_Quit();

    if (rst == 114514) {
        if (geteuid() == 0) execl("/sbin/poweroff", "/sbin/poweroff", NULL);
        else cout << "Shutdown performed" << std::endl;
    } else if (rst == 114515) {
        if (geteuid() == 0) execl("/sbin/reboot", "/sbin/reboot", NULL);
        else cout << "Reboot performed" << std::endl;
    } else if (rst == 114516) {
        cout << "Graphical interface has been disabled due to monitor disconnected during boot." << std::endl;
        cout << "Press Ctrl-D to try getting it back." << std::endl;
        fallback_to_agetty(tty);
    }

    if (error_message) {
        cerr << error_message.value() << std::endl;
        if (tty && ftty) {
            cout << "Hit enter key" << std::endl;
            ftty.get();
        }
    }

    return rst;
}

static int login(const std::vector<std::string>& args)
{
    argparse::ArgumentParser program(args[0]);
    program.add_argument("tty").help("TTY name");
    program.add_argument("--installer").help("Installer mode").default_value(false).implicit_value(true);
    try {
        program.parse_args(args);
    }
    catch (const std::runtime_error& err) {
        std::cout << err.what() << std::endl;
        std::cout << program;
        return 1;
    }
    
    auto tty = program.get<std::string>("tty");

    return ui(tty.c_str(), program.get<bool>("--installer"));
}

static const std::map<std::string,std::pair<int (*)(const std::vector<std::string>&),std::string> > subcommands {
  {"console", {console, "Enter VM console"}},
  {"start", {start, "Start VM"}},
  {"stop", {stop, "Stop VM"}},
  {"autostart", {autostart, "Enable/Disable autostart"}},
  {"list", {list, "List VM"}},
  {"login", {login, "Show title screen(executed by systemd)"}},
  {"ui", {[](auto args){ return ui(); }, "Run graphical interface"}},
  {"installer", {[](auto args){ return ui(NULL, true); }, "Run graphical installer"}},
};

static void show_subcommands()
{
    for (auto i = subcommands.cbegin(); i != subcommands.cend(); i++) {
        std::cout << i->first << '\t' << i->second.second << std::endl;
    }
}

#ifdef __VSCODE_ACTIVE_FILE__
int messagebox_main();

int debug_main(int argc, char* argv[])
{
    if (std::string(__VSCODE_ACTIVE_FILE__) == "messagebox.cpp") {
        return messagebox_main();
    }
    if (std::string(__VSCODE_ACTIVE_FILE__) == "installer.cpp") {
        return ui(NULL, true);
    }
    //else
    std::cout << "No debug main for " << __VSCODE_ACTIVE_FILE__ << std::endl;
    return 0;
}
#endif

static int _main(int argc, char* argv[])
{
#ifdef __VSCODE_ACTIVE_FILE__
    return debug_main(argc, argv);
#endif
    setlocale( LC_ALL, "ja_JP.utf8"); // TODO: read /etc/locale.conf

    if (argc < 2) {
        std::cout << "Subcommand not specified. Valid subcommands are:" << std::endl;
        show_subcommands();
        return 1;
    }

    std::string subcommand(argv[1]);

    if (!subcommands.contains(subcommand)) {
        std::cout << "Invalid subcommand '" << subcommand << "'. Valid subcommands are:" << std::endl;
        show_subcommands();
        return 1;
    }

    std::vector<std::string> args;

    args.push_back(std::string(argv[0]) + ' ' + subcommand);
    for (int i = 2; i < argc; i++) {
        args.push_back(argv[i]);
    }

    return subcommands.at(subcommand).first(args);
}

#ifdef __MAIN_MODULE__
int main(int argc, char* argv[]) { return _main(argc, argv); }
#endif

