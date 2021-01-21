#include <termios.h>
#include <pty.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <iostream>
#include <vector>
#include <functional>
#include <thread>
#include <cstring>
#include <chrono>
#include <unicode/unistr.h>
#include <unicode/normlzr.h>

#include "terminal.h"

Terminal::Terminal(int _fd, int _rows, int _cols, TTF_Font* _font) : fd(_fd), matrix(_rows, _cols), font(_font), font_height(TTF_FontHeight(font))
{
    vterm = vterm_new(_rows,_cols);
    vterm_set_utf8(vterm, 1);
    vterm_output_set_callback(vterm, output_callback, (void*)&fd);

    screen = vterm_obtain_screen(vterm);
    vterm_screen_set_callbacks(screen, &screen_callbacks, this);
    vterm_screen_reset(screen, 1);

    matrix.fill(0);
    TTF_SizeUTF8(font, "X", &font_width, NULL);
    surface = SDL_CreateRGBSurfaceWithFormat(0, font_width * _cols, font_height * _rows, 32, SDL_PIXELFORMAT_RGBA32);
    
    SDL_CreateRGBSurface(0, font_width, font_height, 32, 0, 0, 0, 0);
    //SDL_SetSurfaceBlendMode(surface, SDL_BLENDMODE_BLEND);
}

Terminal::~Terminal()
{
    vterm_free(vterm);
    invalidateTexture();
    SDL_FreeSurface(surface);
}

void Terminal::invalidateTexture()
{
    if (texture) {
        SDL_DestroyTexture(texture);
        texture = NULL;
    }
}

void Terminal::keyboard_unichar(char c, VTermModifier mod) 
{
    vterm_keyboard_unichar(vterm, c, mod);
}

void Terminal::keyboard_key(VTermKey key, VTermModifier mod)
{
    vterm_keyboard_key(vterm, key, mod);
}

void Terminal::input_write(const char* bytes, size_t len)
{
    vterm_input_write(vterm, bytes, len);
}

int Terminal::damage(int start_row, int start_col, int end_row, int end_col)
{
    invalidateTexture();
    for (int row = start_row; row < end_row; row++) {
        for (int col = start_col; col < end_col; col++) {
            matrix(row, col) = 1;
        }
    }
    return 0;
}

int Terminal::moverect(VTermRect dest, VTermRect src)
{
    return 0;
}

int Terminal::movecursor(VTermPos pos, VTermPos oldpos, int visible)
{
    cursor_pos = pos;
    return 0;
}

int Terminal::settermprop(VTermProp prop, VTermValue *val)
{
    return 0;
}

int Terminal::bell()
{
    ringing = true;
    return 0;
}

int Terminal::resize(int rows, int cols)
{
    return 0;
}

int Terminal::sb_pushline(int cols, const VTermScreenCell *cells)
{
    return 0;
}

int Terminal::sb_popline(int cols, VTermScreenCell *cells)
{
    return 0;
}

void Terminal::render(SDL_Renderer* renderer, const SDL_Rect& window_rect)
{
    if (!texture) {
        for (int row = 0; row < matrix.getRows(); row++) {
            for (int col = 0; col < matrix.getCols(); col++) {
                if (matrix(row, col)) {
                    VTermPos pos = { row, col };
                    VTermScreenCell cell;
                    vterm_screen_get_cell(screen, pos, &cell);
                    if (cell.chars[0] == 0xffffffff) continue;
                    icu::UnicodeString ustr;
                    for (int i = 0; cell.chars[i] != 0 && i < VTERM_MAX_CHARS_PER_CELL; i++) {
                        ustr.append((UChar32)cell.chars[i]);
                    }
                    SDL_Color color = (SDL_Color){128,128,128};
                    SDL_Color bgcolor = (SDL_Color){0,0,0};
                    if (VTERM_COLOR_IS_INDEXED(&cell.fg)) {
                        vterm_screen_convert_color_to_rgb(screen, &cell.fg);
                    }
                    if (VTERM_COLOR_IS_RGB(&cell.fg)) {
                        color = (SDL_Color){cell.fg.rgb.red, cell.fg.rgb.green, cell.fg.rgb.blue};
                    }
                    if (VTERM_COLOR_IS_INDEXED(&cell.bg)) {
                        vterm_screen_convert_color_to_rgb(screen, &cell.bg);
                    }
                    if (VTERM_COLOR_IS_RGB(&cell.bg)) {
                        bgcolor = (SDL_Color){cell.bg.rgb.red, cell.bg.rgb.green, cell.bg.rgb.blue};
                    }

                    if (cell.attrs.reverse) std::swap(color, bgcolor);
                    
                    int style = TTF_STYLE_NORMAL;
                    if (cell.attrs.bold) style |= TTF_STYLE_BOLD;
                    if (cell.attrs.underline) style |= TTF_STYLE_UNDERLINE;
                    if (cell.attrs.italic) style |= TTF_STYLE_ITALIC;
                    if (cell.attrs.strike) style |= TTF_STYLE_STRIKETHROUGH;
                    if (cell.attrs.blink) { /*TBD*/ }

                    SDL_Rect rect = { col * font_width, row * font_height, font_width * cell.width, font_height };
                    SDL_FillRect(surface, &rect, SDL_MapRGB(surface->format, bgcolor.r, bgcolor.g, bgcolor.b));

                    if (ustr.length() > 0) {
                        UErrorCode status = U_ZERO_ERROR;
                        auto normalizer = icu::Normalizer2::getNFKCInstance(status);
                        if (U_FAILURE(status)) throw std::runtime_error("unable to get NFKC normalizer");
                        auto ustr_normalized = normalizer->normalize(ustr, status);
                        std::string utf8;
                        if (U_SUCCESS(status)) {
                            ustr_normalized.toUTF8String(utf8);
                        } else {
                            ustr.toUTF8String(utf8);
                        }
                        TTF_SetFontStyle(font, style);
                        auto text_surface = TTF_RenderUTF8_Blended(font, utf8.c_str(), color);
                        SDL_SetSurfaceBlendMode(text_surface, SDL_BLENDMODE_BLEND);
                        SDL_BlitSurface(text_surface, NULL, surface, &rect);
                        SDL_FreeSurface(text_surface);
                    }
                    matrix(row, col) = 0;
                }
            }
        }
        texture = SDL_CreateTextureFromSurface(renderer, surface);
        SDL_SetTextureBlendMode(texture, SDL_BLENDMODE_BLEND);
    }
    SDL_RenderCopy(renderer, texture, NULL, &window_rect);
    // draw cursor
    VTermScreenCell cell;
    vterm_screen_get_cell(screen, cursor_pos, &cell);

    SDL_Rect rect = { cursor_pos.col * font_width, cursor_pos.row * font_height, font_width, font_height };
    // scale cursor
    rect.x = window_rect.x + rect.x * window_rect.w / surface->w;
    rect.y = window_rect.y + rect.y * window_rect.h / surface->h;
    rect.w = rect.w * window_rect.w / surface->w;
    rect.w *= cell.width;
    rect.h = rect.h * window_rect.h / surface->h;
    SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
    SDL_SetRenderDrawColor(renderer, 255,255,255,96 );
    SDL_RenderFillRect(renderer, &rect);
    SDL_SetRenderDrawColor(renderer, 255,255,255,255 );
    SDL_RenderDrawRect(renderer, &rect);

    if (ringing) {
        SDL_SetRenderDrawColor(renderer, 255,255,255,192 );
        SDL_RenderFillRect(renderer, &window_rect);
        ringing = 0;
    }
}

void Terminal::processEvent(const SDL_Event& ev)
{
    if (ev.type == SDL_TEXTINPUT) {
        const Uint8 *state = SDL_GetKeyboardState(NULL);
        int mod = VTERM_MOD_NONE;
        if (state[SDL_SCANCODE_LCTRL] || state[SDL_SCANCODE_RCTRL]) mod |= VTERM_MOD_CTRL;
        if (state[SDL_SCANCODE_LALT] || state[SDL_SCANCODE_RALT]) mod |= VTERM_MOD_ALT;
        if (state[SDL_SCANCODE_LSHIFT] || state[SDL_SCANCODE_RSHIFT]) mod |= VTERM_MOD_SHIFT;
        for (int i = 0; i < strlen(ev.text.text); i++) {
            keyboard_unichar(ev.text.text[i], (VTermModifier)mod);
        }
    } else if (ev.type == SDL_KEYDOWN) {
        switch (ev.key.keysym.sym) {
        case SDLK_RETURN:
        case SDLK_KP_ENTER:
            keyboard_key(VTERM_KEY_ENTER, VTERM_MOD_NONE);
            break;
        case SDLK_BACKSPACE:
            keyboard_key(VTERM_KEY_BACKSPACE, VTERM_MOD_NONE);
            break;
        case SDLK_ESCAPE:
            keyboard_key(VTERM_KEY_ESCAPE, VTERM_MOD_NONE);
            break;
        case SDLK_TAB:
            keyboard_key(VTERM_KEY_TAB, VTERM_MOD_NONE);
            break;
        case SDLK_UP:
            keyboard_key(VTERM_KEY_UP, VTERM_MOD_NONE);
            break;
        case SDLK_DOWN:
            keyboard_key(VTERM_KEY_DOWN, VTERM_MOD_NONE);
            break;
        case SDLK_LEFT:
            keyboard_key(VTERM_KEY_LEFT, VTERM_MOD_NONE);
            break;
        case SDLK_RIGHT:
            keyboard_key(VTERM_KEY_RIGHT, VTERM_MOD_NONE);
            break;
        case SDLK_PAGEUP:
            keyboard_key(VTERM_KEY_PAGEUP, VTERM_MOD_NONE);
            break;
        case SDLK_PAGEDOWN:
            keyboard_key(VTERM_KEY_PAGEDOWN, VTERM_MOD_NONE);
            break;
        case SDLK_HOME:
            keyboard_key(VTERM_KEY_HOME, VTERM_MOD_NONE);
            break;
        case SDLK_END:
            keyboard_key(VTERM_KEY_END, VTERM_MOD_NONE);
            break;
        default:
            if (ev.key.keysym.mod & KMOD_CTRL && ev.key.keysym.sym < 127) {
                //std::cout << ev.key.keysym.sym << std::endl;
                keyboard_unichar(ev.key.keysym.sym, VTERM_MOD_CTRL);
            }
            break;
        }
    }
}

bool Terminal::processInput()
{
    fd_set readfds;
    FD_ZERO(&readfds);
    FD_SET(fd, &readfds);
    timeval timeout = { 0, 0 };
    if (select(fd + 1, &readfds, NULL, NULL, &timeout) > 0) {
        char buf[4096];
        auto size = read(fd, buf, sizeof(buf));
        if (size == 0) return false;
        if (size > 0) {
            input_write(buf, size);
        }
    }
    return true;
}

void Terminal::output_callback(const char* s, size_t len, void* user)
{
    write(*(int*)user, s, len);
}

int Terminal::damage(VTermRect rect, void *user)
{
    return ((Terminal*)user)->damage(rect.start_row, rect.start_col, rect.end_row, rect.end_col);
}

int Terminal::moverect(VTermRect dest, VTermRect src, void *user)
{
    return ((Terminal*)user)->moverect(dest, src);
}

int Terminal::movecursor(VTermPos pos, VTermPos oldpos, int visible, void *user)
{
    return ((Terminal*)user)->movecursor(pos, oldpos, visible);
}

int Terminal::settermprop(VTermProp prop, VTermValue *val, void *user)
{
    return ((Terminal*)user)->settermprop(prop, val);
}

int Terminal::bell(void *user)
{
    return ((Terminal*)user)->bell();
}

int Terminal::resize(int rows, int cols, void *user)
{
    return ((Terminal*)user)->resize(rows, cols);
}

int Terminal::sb_pushline(int cols, const VTermScreenCell *cells, void *user)
{
    return ((Terminal*)user)->sb_pushline(cols, cells);
}

int Terminal::sb_popline(int cols, VTermScreenCell *cells, void *user)
{
   return ((Terminal*)user)->sb_popline(cols, cells);
}

#if 0
std::pair<int, int> createSubprocessWithPty(int rows, int cols, const char* prog, const std::vector<std::string>& args = {}, const char* TERM = "xterm-256color")
{
    int fd;
    struct winsize win = { (unsigned short)rows, (unsigned short)cols, 0, 0 };
    auto pid = forkpty(&fd, NULL, NULL, &win);
    if (pid < 0) throw std::runtime_error("forkpty failed");
    //else
    if (!pid) {
        signal(SIGTERM, SIG_DFL);
        signal(SIGINT, SIG_DFL);
        setenv("TERM", TERM, 1);
        char ** argv = new char *[args.size() + 2];
        argv[0] = strdup(prog);
        for (int i = 1; i <= args.size(); i++) {
            argv[i] = strdup(args[i - 1].c_str());
        }
        argv[args.size() + 1] = NULL;
        if (execvp(prog, argv) < 0) exit(-1);
    }
    //else 
    return { pid, fd };
}

std::pair<int, int> doWithPty(int rows, int cols, std::function<int()> func)
{
    int fd;
    struct winsize win = { (unsigned short)rows, (unsigned short)cols, 0, 0 };
    auto pid = forkpty(&fd, NULL, NULL, &win);
    if (pid < 0) throw std::runtime_error("forkpty failed");
    //else
    if (!pid) {
        signal(SIGTERM, SIG_DFL);
        signal(SIGINT, SIG_DFL);
        _Exit(func());
    }
    //else 
    return { pid, fd };
}

std::pair<pid_t,int> waitpid(pid_t pid, int options)
{
    int status;
    auto done_pid = waitpid(pid, &status, options);
    return {done_pid, status};
}

class Subprocess {
    pid_t pid; // pid = 0 means already done
    int status;
public:
    Subprocess(const char* cmd, const std::vector<std::string>& args = {}) {
        pid = fork();
        if (pid < 0) throw std::runtime_error("fork failed");
        //else
        if (pid > 0) return;
        //else
        char* argv[args.size() + 2];
        argv[0] = strdup(cmd);
        for (int i = 1; i <= args.size(); i++) {
            argv[i] = strdup(args[i - 1].c_str());
        }
        argv[args.size() + 1] = NULL;
        if (execvp(cmd, argv) < 0) _Exit(-1);
    }
    ~Subprocess() {
        getStatus(); // wait if not done yet
    }
    int getStatus() {
        if (!pid) return status;
        //else
        auto donepid = waitpid(pid, &status, 0);
        if (donepid == (pid_t)-1) throw std::runtime_error("waitpid error");
        // else
        if (donepid == pid) pid = 0; // mark as done
        return status;
    }
    operator int() {
        return getStatus();
    }
    operator bool() {
        return getStatus() == 0;
    }
};

int ui(bool login)
{
    SDL_SetHint(SDL_HINT_VIDEO_DOUBLE_BUFFER, "1");
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        std::cerr << SDL_GetError() << std::endl;
    	return 1;
    }
    if (TTF_Init() < 0) {
        std::cerr << "TTF_Init: " << TTF_GetError() << std::endl;
        return 1;
    }
    TTF_Font* font = TTF_OpenFont("/usr/share/fonts/vlgothic/VL-Gothic-Regular.ttf", 48);
    //TTF_Font* font = TTF_OpenFont("RictyDiminished-Regular.ttf", 48);
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

    const int rows = 32, cols = 100;
    auto subprocess = createSubprocessWithPty(rows, cols, getenv("SHELL"), {"-"});
    /*
    auto subprocess = doWithPty(rows, cols, [rows,cols]{
        std::cout << "rows=" << rows << ", cols=" << cols << std::endl;
        if (Subprocess("sleep", {"3"})) {
            std::cout << "sleep OK" << std::endl;
        }
        for (int i = 0; i < 100; i++) {
            std::cout << "count is " << i << std::endl;
            std::this_thread::sleep_for(std::chrono::seconds(1));
        }
        return 5;
    });
    */

    auto pid = subprocess.first;

    Terminal terminal(subprocess.second/*fd*/, rows, cols, font);

    std::pair<pid_t, int> rst;
    while ((rst = waitpid(pid, WNOHANG)).first != pid) {
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255 );
        SDL_RenderClear(renderer);
        SDL_Event ev;
        while(SDL_PollEvent(&ev)) {
            if (ev.type == SDL_QUIT || (ev.type == SDL_KEYDOWN && ev.key.keysym.sym == SDLK_ESCAPE && (ev.key.keysym.mod & KMOD_CTRL))) {
                kill(pid, SIGTERM);
            } else {
                terminal.processEvent(ev);
            }
        }

        terminal.processInput();

        SDL_Rect rect = { 0, 0, 1024, 768 };
        terminal.render(renderer, rect);
        SDL_RenderPresent(renderer);
    }
    std::cout << "Process exit status: " << rst.second << std::endl;

    TTF_Quit();
    SDL_Quit();
    return 0;
}
#endif