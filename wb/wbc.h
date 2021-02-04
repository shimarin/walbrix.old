#include <unistd.h>
#include <functional>
#include <memory>
#include <SDL2/SDL.h>

static const double pi = 3.141592653589793; // std::numbers::pi in C++20

std::shared_ptr<SDL_Surface> create_transparent_surface(int w, int h);

class PerformShutdown : public std::exception {};
class PerformReboot : public std::exception {};
class Terminated : public std::exception {};
class UnrecoverableSDLError : public std::runtime_error {
public:
    UnrecoverableSDLError(const std::string& what) : std::runtime_error(what) {;}
};
class TTFError : public std::exception {};

static inline bool process_event(std::function<bool(const SDL_Event&)> func, std::function<void()> on_quit = [](){ throw Terminated();}) {
    SDL_Event ev;
    while (SDL_PollEvent(&ev)) {
        if (on_quit && ev.type == SDL_QUIT) {
            on_quit();
            return false;
        }
        if (ev.type == SDL_KEYDOWN && ev.key.keysym.sym == SDLK_DELETE) {
            // Ctrl-Alt-Del to reboot
            const Uint8 *state = SDL_GetKeyboardState(NULL);
            if ((state[SDL_SCANCODE_LCTRL] || state[SDL_SCANCODE_RCTRL]) && (state[SDL_SCANCODE_LALT] || state[SDL_SCANCODE_RALT])) {
                if (geteuid() == 0) throw PerformReboot();
            }
        }
        else if (!func(ev)) return false;
    }
    return true;
}
