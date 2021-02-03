#include <functional>
#include <memory>
#include <SDL2/SDL.h>

static const double pi = 3.141592653589793; // std::numbers::pi in C++20

std::shared_ptr<SDL_Surface> create_transparent_surface(int w, int h);

class PerformShutdown : public std::exception {};
class PerformReboot : public std::exception {};

