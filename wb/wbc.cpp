#include <unistd.h>
#include <pty.h>
#include <sys/wait.h>

#include <security/pam_appl.h>
#include <security/pam_misc.h>

#include <argparse/argparse.hpp>

#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <SDL2/SDL_ttf.h>

#include "walbrixd.h"
#include "terminal.h"

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

int stop(const std::vector<std::string>& args)
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

int list(const std::vector<std::string>& args)
{
    execlp("busctl", "busctl", "--system", "call", 
        WALBRIXD_SERVICE_NAME, WALBRIXD_OBJECT_PATH, WALBRIXD_INTERFACE_NAME, 
        "List", NULL
    );

    return 0;
}

bool title(SDL_Renderer* renderer, int width, int height, const char* font_file, const std::filesystem::path& theme_dir)
{
    auto surface = IMG_Load((theme_dir / "title_background.png").c_str());
    auto title_background = SDL_CreateTextureFromSurface(renderer, surface);
    SDL_FreeSurface(surface);

    surface = IMG_Load((theme_dir / "title.png").c_str());
    auto title = SDL_CreateTextureFromSurface(renderer, surface);
    SDL_Rect title_rect = { (width - surface->w) / 2, height * 1 / 3, surface->w, surface->h };
    SDL_FreeSurface(surface);

    TTF_Font* font = TTF_OpenFont(font_file, 48);

    surface = TTF_RenderUTF8_Blended(font, "開始するにはEnterを押してください", (SDL_Color){255, 255, 255, 255});
    SDL_Rect title_message_rect = { (width - surface->w) / 2, height * 3 / 4, surface->w, surface->h };
    auto title_message = SDL_CreateTextureFromSurface(renderer, surface);
    SDL_FreeSurface(surface);

    surface = TTF_RenderUTF8_Blended(font, "Copyright© 2009-2021 Walbrix Corporation", (SDL_Color){0, 0, 0, 0});
    SDL_Rect copyright_rect = { (width - surface->w) / 2, height - surface->h - 20, surface->w, surface->h };
    auto copyright = SDL_CreateTextureFromSurface(renderer, surface);
    SDL_FreeSurface(surface);

    static const double pi = 3.141592653589793; // std::numbers::pi in C++20

    while (true) {
        SDL_RenderCopy(renderer, title_background, NULL, NULL);
        SDL_RenderCopy(renderer, title, NULL, &title_rect);
        SDL_RenderCopy(renderer, copyright, NULL, &copyright_rect);
        SDL_Event ev;
        while(SDL_PollEvent(&ev)) {
            if (ev.type == SDL_QUIT) throw std::runtime_error("Terminated");
            if (ev.type == SDL_KEYDOWN && ev.key.keysym.sym == SDLK_RETURN) {
                goto next;
            }
        }

        Uint8 alpha = std::abs(std::sin((SDL_GetTicks() % 4000 * pi * 2 / 4000))) * 255;
        SDL_SetTextureAlphaMod(title_message, alpha);
        SDL_RenderCopy(renderer, title_message, NULL, &title_message_rect);

        SDL_RenderPresent(renderer);
    }

next:;
    bool rst = true;

    struct Env {
        int width, height;
        SDL_Renderer* renderer;
        SDL_Texture* title_background;
        SDL_Texture* title;
        SDL_Texture* copyright;
        SDL_Rect& title_rect;
        SDL_Rect& copyright_rect;
        TTF_Font* font;
        int result = 0;
        bool cancelled = false;
    } env = {
        width, height, renderer, title_background, title, copyright, title_rect, copyright_rect, font
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
                    std::string password;//("coarse8Gleam_Grin");
                    while (true) {
                        SDL_RenderCopy(env.renderer, env.title_background, NULL, NULL);
                        SDL_RenderCopy(env.renderer, env.title, NULL, &env.title_rect);
                        SDL_RenderCopy(env.renderer, env.copyright, NULL, &env.copyright_rect);
                        std::string message(msg[i]->msg);
                        message += ' ';
                        for (int i = 0; i < password.length(); i++) message += '*';
                        auto surface = TTF_RenderUTF8_Blended(env.font, message.c_str(), (SDL_Color){0, 0, 0, 0});
                        auto password_texture = SDL_CreateTextureFromSurface(env.renderer, surface);
                        SDL_Rect password_rect = { 0, env.height * 3 / 5, surface->w, surface->h };
                        SDL_FreeSurface(surface);
                        SDL_RenderCopy(env.renderer, password_texture, NULL, &password_rect);

                        SDL_Event ev;
                        while(SDL_PollEvent(&ev)) {
                            if (ev.type == SDL_QUIT) throw std::runtime_error("Terminated");
                            if (ev.type == SDL_TEXTINPUT) {
                                for (int i = 0; i < strlen(ev.text.text); i++) {
                                    if (password.length() < 32) password += (char)ev.text.text[i];
                                }
                            } else if (ev.type == SDL_KEYDOWN) {
                                if (ev.key.keysym.sym == SDLK_RETURN || ev.key.keysym.sym == SDLK_KP_ENTER) {
                                    SDL_RenderPresent(env.renderer);
                                    goto out;
                                } else if (ev.key.keysym.sym == SDLK_BACKSPACE) {
                                    if (password.length() > 0) password.pop_back();
                                } else if (ev.key.keysym.sym == SDLK_ESCAPE) {
                                    env.cancelled = true;
                                    SDL_RenderPresent(env.renderer);
                                    goto out;
                                }
                            }
                        }

                        if (env.result == PAM_PERM_DENIED) {
                            surface = TTF_RenderUTF8_Blended(env.font, "パスワードが正しくありません", (SDL_Color){255, 0, 0, 0});
                            auto message_texture = SDL_CreateTextureFromSurface(env.renderer, surface);
                            SDL_Rect message_rect = { 0, password_rect.y + password_rect.h, surface->w, surface->h };
                            SDL_FreeSurface(surface);
                            SDL_RenderCopy(env.renderer, message_texture, NULL, &message_rect);
                        }

                        password_rect.x = password_rect.w;
                        password_rect.w = 4;
                        Uint8 alpha = std::abs(std::sin((SDL_GetTicks() % 2000 * pi * 2 / 2000))) * 255;
                        SDL_SetRenderDrawColor(env.renderer, 0, 0, 0, alpha);
                        SDL_SetRenderDrawBlendMode(env.renderer, SDL_BLENDMODE_BLEND);
                        SDL_RenderFillRect(env.renderer, &password_rect);
                        SDL_RenderPresent(env.renderer);
                    }
                    out:;
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

    if (env.result == PAM_ABORT || env.result == PAM_MAXTRIES || env.cancelled) rst = false;

    TTF_CloseFont(font);
    SDL_DestroyTexture(title_background);
    SDL_DestroyTexture(title);
    SDL_DestroyTexture(title_message);
    SDL_DestroyTexture(copyright);
    return rst;
}

void local_console(SDL_Renderer* renderer, int width, int height, const char* font_file, const std::filesystem::path& theme_dir, 
    const char* prog, const std::vector<std::string>& args = {})
{
    auto surface = IMG_Load((theme_dir / "background.png").c_str());
    auto background = SDL_CreateTextureFromSurface(renderer, surface);
    SDL_FreeSurface(surface);
    surface = IMG_Load((theme_dir / "header.png").c_str());
    auto header = SDL_CreateTextureFromSurface(renderer, surface);
    SDL_Rect header_rect = { 0, 0, surface->w, surface->h };
    SDL_FreeSurface(surface);
    surface = IMG_Load((theme_dir / "header_logo.png").c_str());
    auto header_logo = SDL_CreateTextureFromSurface(renderer, surface);
    SDL_Rect header_logo_rect = { 0, 0, surface->w, surface->h };
    SDL_FreeSurface(surface);
    surface = IMG_Load((theme_dir / "footer.png").c_str());
    auto footer = SDL_CreateTextureFromSurface(renderer, surface);
    SDL_Rect footer_rect = { 0, height - surface->h, surface->w, surface->h };
    SDL_FreeSurface(surface);
    surface = IMG_Load((theme_dir / "mainmenu_panel.png").c_str());
    auto mainmenu_panel = SDL_CreateTextureFromSurface(renderer, surface);
    SDL_Rect mainmenu_panel_rect = { 0, header_rect.h, surface->w, surface->h };
    SDL_FreeSurface(surface);

    const int rows = 30, cols = 100;

    int fd;
    struct winsize win = { (unsigned short)rows, (unsigned short)cols, 0, 0 };
    auto pid = forkpty(&fd, NULL, NULL, &win);
    if (pid < 0) throw std::runtime_error("forkpty failed");
    //else
    if (!pid) {
        signal(SIGTERM, SIG_DFL);
        signal(SIGINT, SIG_DFL);
        setenv("TERM", "xterm-256color", 1);
        char ** argv = new char *[args.size() + 2];
        argv[0] = strdup(prog);
        for (int i = 1; i <= args.size(); i++) {
            argv[i] = strdup(args[i - 1].c_str());
        }
        argv[args.size() + 1] = NULL;
        if (execvp(prog, argv) < 0) exit(-1);
    }
    //else 

    TTF_Font* font = TTF_OpenFont(font_file, 16);
    Terminal terminal(fd, rows, cols, font);
    SDL_Rect terminal_rect = { (width - 800) / 2, (height - 600) / 2, 800, 600 };

    int status;
    while (pid != waitpid(pid, &status, WNOHANG)) {
        SDL_RenderCopy(renderer, background, NULL, NULL);
        SDL_RenderCopy(renderer, header, NULL, &header_rect);
        SDL_RenderCopy(renderer, header_logo, NULL, &header_logo_rect);
        SDL_RenderCopy(renderer, footer, NULL, &footer_rect);
        SDL_RenderCopy(renderer, mainmenu_panel, NULL, &mainmenu_panel_rect);
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        SDL_RenderFillRect(renderer, &terminal_rect);
        SDL_Event ev;
        while(SDL_PollEvent(&ev)) {
            if (ev.type == SDL_QUIT) throw std::runtime_error("Terminated");
            //else
            terminal.processEvent(ev);
        }

        if (!terminal.processInput()) break; // EOF detected

        terminal.render(renderer, terminal_rect);
        SDL_RenderPresent(renderer);
    }

out:;
    TTF_CloseFont(font);
    close(fd);

    SDL_DestroyTexture(background);
    SDL_DestroyTexture(header);
    SDL_DestroyTexture(header_logo);
    SDL_DestroyTexture(footer);
    SDL_DestroyTexture(mainmenu_panel);
}

int ui(bool login)
{
    const int width = 1024, height = 768;
    const char* font_file = "/usr/share/fonts/vlgothic/VL-Gothic-Regular.ttf";

    std::filesystem::path theme_dir1("/usr/share/wb/themes/default");
    std::filesystem::path theme_dir2("./default_theme");

    const auto& theme_dir = std::filesystem::exists(theme_dir1)? theme_dir1 : theme_dir2;

    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        std::cerr << SDL_GetError() << std::endl;
    	return 1;
    }
    if (TTF_Init() < 0) {
        std::cerr << "TTF_Init: " << TTF_GetError() << std::endl;
        return 1;
    }

    SDL_Window* window = SDL_CreateWindow("term",SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,width,height,SDL_WINDOW_SHOWN);
    if (window == NULL) {
        std::cerr << "SDL_CreateWindow: " << SDL_GetError() << std::endl;
    	return 1;
    }
    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_PRESENTVSYNC);
    if (renderer == NULL) {
        std::cerr << "SDL_CreateRenderer: " << SDL_GetError() << std::endl;
    	return 1;
    }

    try {
        if (login) {
            while (!title(renderer, width, height, font_file, theme_dir)) { ; }
            local_console(renderer, width, height, font_file, theme_dir, "bash", {"--login"});
        } else {
            local_console(renderer, width, height, font_file, theme_dir, "bash");
        }
    }
    catch (const std::exception& e) {
        std::cerr << e.what() << std::endl;
    }

    TTF_Quit();
    SDL_Quit();
    return 0;
}

int login(const std::vector<std::string>& args)
{
    return ui(true);
}

int ui(const std::vector<std::string>& args)
{
    return ui(false);
}

static const std::map<std::string,std::pair<int (*)(const std::vector<std::string>&),std::string> > subcommands {
  {"console", {console, "Enter VM console"}},
  {"start", {start, "Start VM"}},
  {"stop", {stop, "Stop VM"}},
  {"list", {list, "List VM"}},
  {"login", {login, "Show title screen(executed by systemd)"}},
  {"ui", {ui, "Run graphical interface"}},
};

void show_subcommands()
{
    for (auto i = subcommands.cbegin(); i != subcommands.cend(); i++) {
        std::cout << i->first << '\t' << i->second.second << std::endl;
    }
}

int main(int argc, char* argv[])
{
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
