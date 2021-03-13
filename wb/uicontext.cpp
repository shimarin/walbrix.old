#include "uicontext.h"

#include <SDL2/SDL_image.h>

SDL_Surface* SurfaceRegistry::load(const std::string& name)
{
    auto surface = IMG_Load((resource_path / name).c_str());
    if (!surface) throw std::runtime_error(std::string("Failed to load image resource '") + name + "'.");
    //else
    return surface;
}

std::shared_ptr<SDL_Surface> SurfaceRegistry::transient(const std::string& name)
{
    return std::shared_ptr<SDL_Surface>(load(name), SDL_FreeSurface);
}


TTF_Font* FontRegistry::load(const std::pair<std::string,uint8_t>& name)
{
    auto font = TTF_OpenFont((resource_path / name.first).c_str(), name.second);
    if (!font) font = TTF_OpenFont((system_font_path / name.first).c_str(), name.second);
    if (!font) throw std::runtime_error(std::string("Failed to load font '") + name.first + "'.");
    //else
    return font;
}

std::tuple<std::shared_ptr<SDL_Texture>,int,int> UIContext::create_texture_from_transient_surface(const char* name)
{
    auto surface = registry.surfaces.transient(name);
    auto texture = std::shared_ptr<SDL_Texture>(SDL_CreateTextureFromSurface(renderer.get(), surface.get()),SDL_DestroyTexture);
    auto w = surface->w;
    auto h = surface->h;
    return std::make_tuple(texture, w, h);
};

std::tuple<std::shared_ptr<SDL_Texture>,int,int> UIContext::render_font_as_texture(std::pair<std::string,uint8_t> font_def, const char* text, const SDL_Color& color) {
    auto font = registry.fonts(font_def);
    auto surface = TTF_RenderUTF8_Blended(font, text, (SDL_Color){255, 255, 255, 255});
    int w = surface->w;
    int h = surface->h;
    auto texture = SDL_CreateTextureFromSurface(renderer.get(), surface);
    SDL_FreeSurface(surface);
    return std::make_tuple(std::shared_ptr<SDL_Texture>(texture, SDL_DestroyTexture), w, h);
};

void UIContext::render()
{
    for (auto i = render_funcs.begin(); i != render_funcs.end(); i++) {
        (*i)(*this, i == std::next(render_funcs.end(), -1));
    }
}

static int _main(int,char*[])
{
    return 0;
}

#ifdef __MAIN_MODULE__
int main(int argc, char* argv[]) { return _main(argc, argv); }
#endif

