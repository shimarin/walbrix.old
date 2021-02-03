#include <iostream>
#include "sdlplusplus.h"
#include "wbc.h"
#include "messagebox.h"
#include "shutdown.h"

static void blink(SDL_Texture* texture)
{
    Uint8 alpha = std::abs(std::sin((SDL_GetTicks() % 4000 * pi * 2 / 4000))) * 127 + 128;
    SDL_SetTextureAlphaMod(texture, alpha);
}

void Shutdown::draw(SDL_Renderer* renderer/*=NULL*/, bool focus/* = false*/)
{
    if (!renderer) renderer = uicontext.renderer;
    auto item_left = uicontext.mainmenu_width + (uicontext.width - uicontext.mainmenu_width - item_width) / 2;
    auto item_top = uicontext.header_height + 100;
    SDL_Rect rect {
        item_left, item_top, item_width, item_height
    };

    if (focus) {
        blink(textures.selected.get());
    } else {
        SDL_SetTextureAlphaMod(textures.selected.get(), 255);
    }

    if (selected == 0) {
        SDL_RenderCopy(renderer, textures.selected.get(), NULL, &rect);
    } else {
        SDL_RenderCopy(renderer, textures.notselected.get(), NULL, &rect);
    }

    SDL_Rect rect2 {
        item_left + (item_width - shutdown_text_size.first) / 2, item_top + (item_height - shutdown_text_size.second) / 2,
        shutdown_text_size.first, shutdown_text_size.second
    };
    SDL_RenderCopy(renderer, textures.shutdown.get(), NULL, &rect2);

    item_top += item_height + 20;
    rect.y = item_top;
    if (selected == 1) {
        SDL_RenderCopy(renderer, textures.selected.get(), NULL, &rect);
    } else {
        SDL_RenderCopy(renderer, textures.notselected.get(), NULL, &rect);
    }
    rect2.x = item_left + (item_width - reboot_text_size.first) / 2;
    rect2.y = item_top + (item_height - reboot_text_size.second) / 2;
    rect2.w = reboot_text_size.first;
    rect2.h = reboot_text_size.second;
    SDL_RenderCopy(renderer, textures.reboot.get(), NULL, &rect2);
}

void Shutdown::on_select()
{
    auto font_def = std::make_pair(uicontext.FONT_PROPOTIONAL, 32);

    auto notselected = uicontext.registry.surfaces("shutdown_notselected.png");
    item_width = notselected->w;
    item_height = notselected->h;
    textures.notselected = std::shared_ptr<SDL_Texture>(SDL_CreateTextureFromSurface(uicontext.renderer, notselected), SDL_DestroyTexture);
    textures.selected = std::shared_ptr<SDL_Texture>(SDL_CreateTextureFromSurface(uicontext.renderer, uicontext.registry.surfaces("shutdown_selected.png")), SDL_DestroyTexture);

    auto shutdown = uicontext.render_font_as_texture(font_def, "シャットダウン", {255, 255, 255, 255});
    textures.shutdown = std::get<0>(shutdown);
    shutdown_text_size.first = std::get<1>(shutdown);
    shutdown_text_size.second = std::get<2>(shutdown);

    auto reboot = uicontext.render_font_as_texture(font_def, "再起動", {255, 255, 255, 255});
    textures.reboot = std::get<0>(reboot);
    reboot_text_size.first = std::get<1>(reboot);
    reboot_text_size.second = std::get<2>(reboot);
}

void Shutdown::on_deselect()
{
    textures.notselected = textures.selected = textures.shutdown = textures.reboot = NULL;
}

bool Shutdown::on_enter()
{
    selected = 0;
    uicontext.push_render_func([this](auto renderer, bool focus) {
        draw(renderer, focus);
        return true;
    });

    while (true) {
        while (true) {
            uicontext.render();
            if (!process_event([this](auto ev) {
                if (ev.type == SDL_KEYDOWN) {
                    if (ev.key.keysym.sym == SDLK_UP) {
                        selected = 0;
                    } else if (ev.key.keysym.sym == SDLK_DOWN) {
                        selected = 1;
                    } else if (ev.key.keysym.sym == SDLK_RETURN || ev.key.keysym.sym == SDLK_KP_ENTER) {
                        return false;
                    } else if (ev.key.keysym.sym == SDLK_ESCAPE) {
                        selected = -1;
                        return false;
                    }
                }
                return true;
            })) break;
            SDL_RenderPresent(uicontext.renderer);
        }

        if (selected < 0) break;
        //else
        auto message = std::string("システムを") + (selected == 0? "シャットダウン" : "再起動") + "します。よろしいですか？";
        if (messagebox_okcancel(uicontext, message, false, true)) {
            uicontext.pop_render_func();
            if (selected == 0) throw PerformShutdown();
            else throw PerformReboot();
        }
    }

    uicontext.pop_render_func();

    return true;
}