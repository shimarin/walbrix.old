#ifndef __UICONTEXT_H__
#define __UICONTEXT_H__

#include <list>
#include <map>
#include <functional>
#include <filesystem>
#include <tuple>

#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>

template <typename K, typename T, void F(T*)> class Registry {
    std::map<K, std::shared_ptr<T> > resources;
protected:
    virtual T* load(const K& name) = 0;
public:
    T* operator()(const K& name) {
        auto i = resources.find(name);
        if (i != resources.end()) return i->second.get();
        //else
        auto newi = load(name);
        if (!newi) throw std::runtime_error("Resource not found.");
        //else
        resources.insert({name, std::shared_ptr<T>(newi, F) }); 
        return newi;
    }
    void operator()(const K& name, T* item) {
        auto i = resources.find(name);
        if (i != resources.end()) i.remove();
        resources.insert({name, std::shared_ptr<T>(item, F) }); 
    }
    void discard(const K& name) { resources.erase(name); }
};

class SurfaceRegistry : public Registry<std::string, SDL_Surface, SDL_FreeSurface> {
    std::filesystem::path resource_path;
protected:
    virtual SDL_Surface* load(const std::string& name);
public:
    SurfaceRegistry(const std::filesystem::path& _resource_path) : resource_path(_resource_path) {;}
    std::shared_ptr<SDL_Surface> transient(const std::string& name);
};

class FontRegistry : public Registry<std::pair<std::string,uint8_t>, TTF_Font, TTF_CloseFont> {
    const std::filesystem::path system_font_path = "/usr/share/fonts";
    std::filesystem::path resource_path;
protected:
    virtual TTF_Font* load(const std::pair<std::string,uint8_t>& name);
public:
    FontRegistry(const std::filesystem::path& _resource_path) : resource_path(_resource_path) {;}
};

class UIContext {
    std::list<std::function<bool(UIContext&,bool)> > render_funcs;
    std::shared_ptr<SDL_Renderer> renderer;
public:
    bool installer = false;
    int width, height;

    int mainmenu_width;
    int header_height;
    int footer_height;
    int mainmenu_item_height = 48;

    const char* tty;

    const std::string FONT_FIXED = "vlgothic/VL-Gothic-Regular.ttf";
    const std::string FONT_PROPOTIONAL = "vlgothic/VL-PGothic-Regular.ttf";

    struct R {
        SurfaceRegistry surfaces;
        FontRegistry fonts;
        R(std::shared_ptr<SDL_Renderer> renderer, const std::filesystem::path& resource_path) : surfaces(resource_path), fonts(resource_path) {;}
    } registry;

    const std::filesystem::path resource_path;

    UIContext(std::shared_ptr<SDL_Renderer> _renderer, const std::filesystem::path& _resource_path, const char* _tty = NULL, bool _installer = false) : renderer(_renderer), resource_path(_resource_path), registry(_renderer, _resource_path), tty(_tty), installer(_installer) {
        SDL_GetRendererOutputSize(renderer.get(), &width, &height);
    }

    operator SDL_Renderer*() const { return renderer.get(); }

    void push_render_func(std::function<bool(UIContext&,bool)> func) { render_funcs.push_back(func); }
    void pop_render_func() { render_funcs.pop_back(); }

    std::tuple<std::shared_ptr<SDL_Texture>,int,int> create_texture_from_transient_surface(const char* name);
    std::tuple<std::shared_ptr<SDL_Texture>,int,int> render_font_as_texture(std::pair<std::string,uint8_t> font, const char* text, const SDL_Color& color);

    SDL_Rect screen_rect() { return SDL_Rect { 0, 0, width, height }; }
    SDL_Rect header_rect() { return SDL_Rect { 0, 0, width, header_height }; }
    SDL_Rect mainmenu_rect() { return SDL_Rect { 0, 0, mainmenu_width, height - header_height - footer_height }; }
    SDL_Rect footer_rect() { return SDL_Rect { 0, height - footer_height, width, footer_height }; }
    SDL_Rect center_rect(int w, int h) { return SDL_Rect{ (width - w) / 2, (height - h) / 2, w, h }; }

    void render();
};

class RenderFunc {
    UIContext& uicontext;
public:
    RenderFunc(UIContext& _uicontext, std::function<bool(UIContext&,bool)> func) : uicontext(_uicontext) {
        uicontext.push_render_func(func);
    }
    ~RenderFunc() {
        uicontext.pop_render_func();
    }
};

#endif