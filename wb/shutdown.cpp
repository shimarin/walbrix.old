#include <iostream>
#include "wbc.h"
#include "shutdown.h"

static void blink(SDL_Texture* texture)
{
    Uint8 alpha = std::abs(std::sin((SDL_GetTicks() % 4000 * pi * 2 / 4000))) * 127 + 128;
    SDL_SetTextureAlphaMod(texture, alpha);
}

static bool messagebox_okcancel(UIContext& uicontext, const char* message, bool default_value = true, bool caution = false)
{
    auto window_lefttop = uicontext.registry.surfaces("window_lefttop.png");
    auto window_top = uicontext.registry.surfaces("window_top.png");
    auto window_righttop = uicontext.registry.surfaces("window_righttop.png");
    auto window_left = uicontext.registry.surfaces("window_left.png");
    auto window_center = uicontext.registry.surfaces("window_center.png");
    auto window_right = uicontext.registry.surfaces("window_right.png");
    auto window_leftbottom2 = uicontext.registry.surfaces("window_leftbottom2.png");
    auto window_bottom2 = uicontext.registry.surfaces("window_bottom2.png");
    auto window_rightbottom2 = uicontext.registry.surfaces("window_rightbottom2.png");
    auto caution_sign = uicontext.registry.surfaces("caution_sign.png");

    auto font_def = std::make_pair(uicontext.FONT_PROPOTIONAL, 24);
    auto message_surface = std::shared_ptr<SDL_Surface>(TTF_RenderUTF8_Blended(uicontext.registry.fonts(font_def), message, {0,0,0,255}), SDL_FreeSurface);

    auto content_width = std::max(message_surface->w, caution_sign->w);
    auto content_height = message_surface->h + (caution? caution_sign->h : 0);

    auto message_window_base_surface = create_transparent_surface(
        window_left->w + content_width + window_right->w, window_top->h + content_height + window_bottom2->h );
    SDL_Rect rect { 0, 0, window_lefttop->w, window_lefttop->h };
    SDL_BlitSurface(window_lefttop, NULL, message_window_base_surface.get(), &rect);
    rect.x += rect.w;
    rect.w = content_width;
    rect.h = window_top->h;
    SDL_BlitScaled(window_top, NULL, message_window_base_surface.get(), &rect);
    rect.x += rect.w;
    rect.w = window_righttop->w;
    rect.h = window_righttop->h;
    SDL_BlitSurface(window_righttop, NULL, message_window_base_surface.get(), &rect);
    rect.x = 0;
    rect.y += rect.h;
    rect.w = window_left->w;
    rect.h = content_height;
    SDL_BlitScaled(window_left, NULL, message_window_base_surface.get(), &rect);
    rect.x += rect.w;
    rect.w = message_surface->w;
    rect.h = content_height;
    SDL_BlitScaled(window_center, NULL, message_window_base_surface.get(), &rect);
    rect.x += rect.w;
    rect.w = window_right->w;
    rect.h = content_height;
    SDL_BlitScaled(window_right, NULL, message_window_base_surface.get(), &rect);
    rect.x = 0;
    rect.y += rect.h;
    rect.w = window_leftbottom2->w;
    rect.h = window_leftbottom2->h;
    SDL_BlitSurface(window_leftbottom2, NULL, message_window_base_surface.get(), &rect);
    rect.x += rect.w;
    rect.w = content_width;
    rect.h = window_bottom2->h;
    SDL_BlitScaled(window_bottom2, NULL, message_window_base_surface.get(), &rect);
    rect.x += rect.w;
    rect.w = window_rightbottom2->w;
    rect.h = window_rightbottom2->h;
    SDL_BlitSurface(window_rightbottom2, NULL, message_window_base_surface.get(), &rect);

    rect.y = window_top->h;
    if (caution) {
        rect.x = (message_window_base_surface->w - caution_sign->w) / 2;
        rect.w = caution_sign->w;
        rect.h = caution_sign->h;
        SDL_BlitSurface(caution_sign, NULL, message_window_base_surface.get(), &rect);
        rect.y += rect.h;
    }
    rect.x = (message_window_base_surface->w - message_surface->w) / 2;
    rect.w = message_surface->w;
    rect.h = message_surface->h;
    SDL_BlitSurface(message_surface.get(), NULL, message_window_base_surface.get(), &rect);
    message_surface = NULL; // free surface

    auto message_window_base_texture = std::shared_ptr<SDL_Texture>(SDL_CreateTextureFromSurface(uicontext.renderer, message_window_base_surface.get()), SDL_DestroyTexture);
    int width = message_window_base_surface->w;
    int height = message_window_base_surface->h;
    message_window_base_surface = NULL; // free surface

    // buttons
    auto dialog_button_notselected = uicontext.registry.surfaces("dialog_button_notselected.png");
    auto dialog_button_selected = uicontext.registry.surfaces("dialog_button_selected.png");
    auto button_gap = 32;
    SDL_Rect leftbutton_rect {
        (width - dialog_button_selected->w * 2 - button_gap) / 2,
        height - window_bottom2->h + 12,
        dialog_button_selected->w, dialog_button_selected->h
    };
    SDL_Rect rightbutton_rect {
        leftbutton_rect.x + dialog_button_selected->w + button_gap,
        leftbutton_rect.y,
        dialog_button_selected->w, dialog_button_selected->h
    };

    auto create_button_texture = [&uicontext,width,height](SDL_Surface* button_surface, SDL_Rect& button_rect) {
        auto surface = create_transparent_surface(width, height);
        SDL_BlitSurface(button_surface, NULL, surface.get(), &button_rect);
        return std::shared_ptr<SDL_Texture>(SDL_CreateTextureFromSurface(uicontext.renderer, surface.get()), SDL_DestroyTexture);
    };

    auto leftbutton_notselected_texture = create_button_texture(dialog_button_notselected, leftbutton_rect);
    auto leftbutton_selected_texture = create_button_texture(dialog_button_selected, leftbutton_rect);
    auto rightbutton_notselected_texture = create_button_texture(dialog_button_notselected, rightbutton_rect);
    auto rightbutton_selected_texture = create_button_texture(dialog_button_selected, rightbutton_rect);

    auto buttontext_surface = create_transparent_surface(width, height);
    auto ok_surface = std::shared_ptr<SDL_Surface>(TTF_RenderUTF8_Blended(uicontext.registry.fonts(font_def), "OK", {0,0,0,255}), SDL_FreeSurface);
    auto cancel_surface = std::shared_ptr<SDL_Surface>(TTF_RenderUTF8_Blended(uicontext.registry.fonts(font_def), "キャンセル", {0,0,0,255}), SDL_FreeSurface);
    SDL_Rect ok_rect {
        leftbutton_rect.x + leftbutton_rect.w / 2 - ok_surface->w / 2, leftbutton_rect.y + leftbutton_rect.h / 2 - ok_surface->h / 2,
        ok_surface->w, ok_surface->h
    };
    SDL_Rect cancel_rect {
        rightbutton_rect.x + rightbutton_rect.w / 2 - cancel_surface->w / 2, rightbutton_rect.y + rightbutton_rect.h / 2 - cancel_surface->h / 2,
        cancel_surface->w, cancel_surface->h
    };
    SDL_BlitSurface(ok_surface.get(), NULL, buttontext_surface.get(), &ok_rect);
    SDL_BlitSurface(cancel_surface.get(), NULL, buttontext_surface.get(), &cancel_rect);
    ok_surface = NULL; // free surface
    cancel_surface = NULL; // free surface

    auto buttontext_texture = std::shared_ptr<SDL_Texture>(SDL_CreateTextureFromSurface(uicontext.renderer, buttontext_surface.get()), SDL_DestroyTexture);
    buttontext_surface = NULL; // free surface

    bool ok = default_value;

    uicontext.push_render_func([&uicontext,width,height,&message_window_base_texture,
        &leftbutton_notselected_texture,&leftbutton_selected_texture,&rightbutton_notselected_texture,&rightbutton_selected_texture,
        &buttontext_texture,&ok](auto renderer,bool) {
        SDL_Rect rect {
            (uicontext.width - width) / 2,
            (uicontext.height - height) / 2,
            width, height
        };
        SDL_RenderCopy(renderer, message_window_base_texture.get(), NULL, &rect);

        blink(leftbutton_selected_texture.get());
        blink(rightbutton_selected_texture.get());
        SDL_RenderCopy(renderer, ok? leftbutton_selected_texture.get() : leftbutton_notselected_texture.get(), NULL, &rect);
        SDL_RenderCopy(renderer, ok? rightbutton_notselected_texture.get() : rightbutton_selected_texture.get(), NULL, &rect);

        SDL_RenderCopy(renderer, buttontext_texture.get(), NULL, &rect);
        return true;
    });

    while (true) {
        uicontext.render();
        if (!process_event([&ok](auto ev) {
            if (ev.type == SDL_KEYDOWN) {
                if (ev.key.keysym.sym == SDLK_LEFT) {
                    ok = true;
                } else if (ev.key.keysym.sym == SDLK_RIGHT) {
                    ok = false;
                } else if (ev.key.keysym.sym == SDLK_RETURN || ev.key.keysym.sym == SDLK_KP_ENTER) {
                    return false;
                } else if (ev.key.keysym.sym == SDLK_ESCAPE) {
                    ok = false;
                    return false;
                }
            }
            return true;
        })) break;
        SDL_RenderPresent(uicontext.renderer);
    }

    uicontext.pop_render_func();

    return ok;
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
        if (messagebox_okcancel(uicontext, message.c_str(), false, true)) {
            uicontext.pop_render_func();
            if (selected == 0) throw PerformShutdown();
            else throw PerformReboot();
        }
    }

    uicontext.pop_render_func();

    return true;
}