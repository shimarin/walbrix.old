#include <unistd.h>
#include <poll.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <termios.h>

#include <iostream>
#include <filesystem>
#include <cstdlib>
#include <sys/ioctl.h>
#include <argparse/argparse.hpp>

#include "terminal.h"
#include "walbrixd.h"

static struct termios old_term;

void restore_term()
{
    tcsetattr(STDIN_FILENO, TCSANOW, &old_term);
}

int connect(const char* vmname)
{
    struct sockaddr_un sockaddr;
    memset(&sockaddr, 0, sizeof(sockaddr));

    auto sock = socket(AF_UNIX, SOCK_STREAM, 0);
    if (sock < 0) throw std::runtime_error("Cannot create socket");

    sockaddr.sun_family = AF_UNIX;
    strcpy(sockaddr.sun_path, (WALBRIXD_CONSOLE_SOCKET_BASE_DIR / vmname).c_str());

    if (connect(sock, (const struct sockaddr *)&sockaddr, sizeof(sockaddr)) < 0) {
        close(sock);
        throw std::runtime_error("Failed to connect");
    }

    return sock;
}

int send_window_size(int fd, unsigned short rows, unsigned short cols)
{
    uint8_t cmd_window_size[] {
        0xff/*IAC*/, 0xfa/*SB*/, 0x1f/*window_size*/, 
        (uint8_t)(cols >> 8), (uint8_t)(cols & 0xff)/*cols*/, 
        (uint8_t)(rows >> 8), (uint8_t)(rows & 0xff)/*rows*/
    };

    return write(fd, cmd_window_size, sizeof(cmd_window_size));
}

int console(const char* vmname)
{
    int sock = connect(vmname);

    // send window size
    struct winsize winsz;
    if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &winsz) >= 0) {
        send_window_size(sock, winsz.ws_row, winsz.ws_col);
    }

    // init terminal
    if (tcgetattr(STDIN_FILENO, &old_term) >= 0) {
        struct termios new_term;
        memcpy(&new_term, &old_term, sizeof(new_term));
        cfmakeraw(&new_term);
        tcsetattr(STDIN_FILENO, TCSANOW, &new_term);
        std::atexit(restore_term);
    }

    while(true) {
        struct pollfd pollfds[2];
        pollfds[0].fd = sock;
        pollfds[0].events = POLLIN;
        pollfds[1].fd = STDIN_FILENO;
        pollfds[1].events = POLLIN;

        poll(pollfds, 2, 1000);

        char buf[4096];

        if (pollfds[0].revents & POLLIN) {
            auto r = read(sock, buf, sizeof(buf));
            if (r == 0) { // EOF
                break;
            }
            //else
            write(STDOUT_FILENO, buf, r);
        }

        if (pollfds[1].revents & POLLIN) {
            auto r = read(STDIN_FILENO, buf, sizeof(buf));
            if (r == 0) { // EOF
                break;
            }
            //else
            for (int i = 0; i < r; i++) {
                if (buf[i] == 29/*C-]*/) goto out;
                write(sock, &buf[i], 1);
            }
        }

    }
out:;

    close(sock);
    return 0;
}

int console_graphical(const char* vmname)
{
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        std::cerr << SDL_GetError() << std::endl;
    	return 1;
    }
    if (TTF_Init() < 0) {
        std::cerr << "TTF_Init: " << TTF_GetError() << std::endl;
        return 1;
    }
    TTF_Font* font = TTF_OpenFont("/usr/share/fonts/vlgothic/VL-Gothic-Regular.ttf", 48);
    if (font == NULL) {
        std::cerr << "TTF_OpenFont: " << TTF_GetError() << std::endl;
        return 1;
    }
    SDL_ShowCursor(SDL_DISABLE);
    SDL_Window* window = SDL_CreateWindow("term",SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,1024,768,SDL_WINDOW_SHOWN);
    if (window == NULL) {
        std::cerr << "SDL_CreateWindow: " << SDL_GetError() << std::endl;
    	return 1;
    }
    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_PRESENTVSYNC);
    if (renderer == NULL) {
        std::cerr << "SDL_CreateRenderer: " << SDL_GetError() << std::endl;
    	return 1;
    }

    int sock = connect(vmname);

    const int rows = 24, cols = 80;
    send_window_size(sock, rows, cols);

    Terminal terminal(sock, rows, cols, font);

    while (true) {
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255 );
        SDL_RenderClear(renderer);
        SDL_Event ev;
        while(SDL_PollEvent(&ev)) {
            if (ev.type == SDL_QUIT || (ev.type == SDL_KEYDOWN && ev.key.keysym.sym == SDLK_RIGHTBRACKET && (ev.key.keysym.mod & KMOD_CTRL))) {
                goto out;
            } else {
                terminal.processEvent(ev);
            }
        }

        if (!terminal.processInput()) break; // EOF detected

        SDL_Rect rect = { 0, 0, 1024, 768 };
        terminal.render(renderer, rect);
        SDL_RenderPresent(renderer);
    }

out:;
    close(sock);

    TTF_Quit();
    SDL_Quit();
    return 0;
}

int console(const std::vector<std::string>& args)
{
    argparse::ArgumentParser program(args[0]);
    program.add_argument("--graphical", "-g").help("Graphical console").default_value(false).implicit_value(true);
    program.add_argument("vmname").help("VM name");

    try {
        program.parse_args(args);
    }
    catch (const std::runtime_error& err) {
        std::cout << err.what() << std::endl;
        std::cout << program;
        return 1;
    }

    auto graphical = program.get<bool>("--graphical"); 
    auto vmname = program.get<std::string>("vmname");
    return graphical? console_graphical(vmname.c_str()) 
     : console(vmname.c_str());
}
