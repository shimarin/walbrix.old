#include <SDL2/SDL.h>
#include <memory>
#include <functional>

static inline std::shared_ptr<SDL_Window> make_shared(SDL_Window* window)
{
    return std::shared_ptr<SDL_Window>(window, SDL_DestroyWindow);
}

static inline std::shared_ptr<SDL_Renderer> make_shared(SDL_Renderer* renderer)
{
    return std::shared_ptr<SDL_Renderer>(renderer, SDL_DestroyRenderer);
}

static inline std::shared_ptr<SDL_Surface> make_shared(SDL_Surface* surface)
{
    return std::shared_ptr<SDL_Surface>(surface, SDL_FreeSurface);
}

static inline std::shared_ptr<SDL_Texture> make_shared(SDL_Texture* texture)
{
    return std::shared_ptr<SDL_Texture>(texture, SDL_DestroyTexture);
}

static inline std::tuple<std::shared_ptr<SDL_Texture>,int,int> create_texture_from_surface(SDL_Renderer* renderer, std::function<std::shared_ptr<SDL_Surface>()> func)
{
    auto surface = func();
    auto texture = SDL_CreateTextureFromSurface(renderer, surface.get());
    auto w = surface->w;
    auto h = surface->h;
    return {make_shared(texture), w, h};
}

static inline std::shared_ptr<SDL_Texture> create_texture_from_surface(SDL_Renderer* renderer, int width, int height, std::function<void(SDL_Surface*)> func)
{
    auto surface = SDL_CreateRGBSurface(0, width, height, 32,0xff, 0xff00, 0xff0000, 0xff000000);
    func(surface);
    auto texture = make_shared(SDL_CreateTextureFromSurface(renderer, surface));
    SDL_FreeSurface(surface);
    return texture;
}

static inline std::shared_ptr<SDL_Surface> with_transparent_surface(int width, int height, std::function<void(SDL_Surface*)> func)
{
    auto surface = SDL_CreateRGBSurface(0, width, height, 32,0xff, 0xff00, 0xff0000, 0xff000000);
    func(surface);
    return make_shared(surface);
}
