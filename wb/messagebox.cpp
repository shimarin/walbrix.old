#include <iostream>
#include "sdlplusplus.h"
#include "uicontext.h"
#include "wbc.h"

static void blink(SDL_Texture* texture)
{
    Uint8 alpha = std::abs(std::sin((SDL_GetTicks() % 4000 * pi * 2 / 4000))) * 127 + 128;
    SDL_SetTextureAlphaMod(texture, alpha);
}

static std::tuple<std::shared_ptr<SDL_Surface>,int/*left*/,int/*top*/,int/*buttonarea_height*/> generate_window_frame(UIContext& uicontext, int content_width, int content_height)
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

    return std::make_tuple(
        with_transparent_surface(window_left->w + content_width + window_right->w, window_top->h + content_height + window_bottom2->h , [&](auto surface) {
            SDL_Rect rect { 0, 0, window_lefttop->w, window_lefttop->h };
            SDL_BlitSurface(window_lefttop, NULL, surface, &rect);
            rect.x += rect.w;
            rect.w = content_width;
            rect.h = window_top->h;
            SDL_BlitScaled(window_top, NULL, surface, &rect);
            rect.x += rect.w;
            rect.w = window_righttop->w;
            rect.h = window_righttop->h;
            SDL_BlitSurface(window_righttop, NULL, surface, &rect);
            rect.x = 0;
            rect.y += rect.h;
            rect.w = window_left->w;
            rect.h = content_height;
            SDL_BlitScaled(window_left, NULL, surface, &rect);
            rect.x += rect.w;
            rect.w = content_width;
            rect.h = content_height;
            SDL_BlitScaled(window_center, NULL, surface, &rect);
            rect.x += rect.w;
            rect.w = window_right->w;
            rect.h = content_height;
            SDL_BlitScaled(window_right, NULL, surface, &rect);
            rect.x = 0;
            rect.y += rect.h;
            rect.w = window_leftbottom2->w;
            rect.h = window_leftbottom2->h;
            SDL_BlitSurface(window_leftbottom2, NULL, surface, &rect);
            rect.x += rect.w;
            rect.w = content_width;
            rect.h = window_bottom2->h;
            SDL_BlitScaled(window_bottom2, NULL, surface, &rect);
            rect.x += rect.w;
            rect.w = window_rightbottom2->w;
            rect.h = window_rightbottom2->h;
            SDL_BlitSurface(window_rightbottom2, NULL, surface, &rect);
        }),
        window_left->w,
        window_top->h,
        60
    );
}

std::tuple<std::shared_ptr<SDL_Texture>,int/*width*/,int/*height*/,SDL_Rect/*content_rect*/,int/*buttonarea_height*/> create_window_texture_from_surface(
    UIContext& uicontext, std::function<std::shared_ptr<SDL_Surface>(UIContext&)> func)
{
    auto content = func(uicontext);
    auto const& [window_frame, left, top, buttonarea_height] = generate_window_frame(uicontext, content->w, content->h);
    SDL_Rect content_rect { left, top, content->w, content->h };
    SDL_BlitSurface(content.get(), NULL, window_frame.get(), &content_rect);
    return make_tuple(make_shared(SDL_CreateTextureFromSurface(uicontext, window_frame.get())), window_frame->w, window_frame->h, content_rect, buttonarea_height);
}

bool messagebox_okcancel(UIContext& uicontext, std::function<std::shared_ptr<SDL_Surface>(UIContext&)> func, bool default_value/* = true*/)
{
    auto dialog_button = uicontext.registry.surfaces("dialog_button.png");
    auto button_gap = 32;

    auto const& [window_texture,width,height,content_rect,buttonarea_height] = create_window_texture_from_surface(uicontext, [dialog_button,button_gap,func](auto uicontext) {
        auto message_surface = func(uicontext);
        auto content_width = std::max(message_surface->w, dialog_button->w * 2 + button_gap);
        auto content_height = message_surface->h;

        return with_transparent_surface(content_width, content_height, [message_surface](auto surface) {
            SDL_Rect rect { (surface->w - message_surface->w) / 2, 0, message_surface->w, message_surface->h };
            SDL_BlitSurface(message_surface.get(), NULL, surface, &rect);
        });
    });

    // buttons
    auto dialog_button_selection = uicontext.registry.surfaces("dialog_button_selection.png");
    SDL_Rect leftbutton_rect {
        (width - dialog_button->w * 2 - button_gap) / 2,
        content_rect.y + content_rect.h + (buttonarea_height - dialog_button->h) / 2,
        dialog_button->w, dialog_button->h
    };
    SDL_Rect rightbutton_rect {
        leftbutton_rect.x + dialog_button->w + button_gap,
        leftbutton_rect.y,
        dialog_button->w, dialog_button->h
    };

    auto buttons_texture = create_texture_from_surface(uicontext, width, height, [dialog_button,&leftbutton_rect,&rightbutton_rect](auto surface) {
        SDL_BlitSurface(dialog_button, NULL, surface, &leftbutton_rect);
        SDL_BlitSurface(dialog_button, NULL, surface, &rightbutton_rect);
    });

    auto leftbutton_selected_texture = create_texture_from_surface(uicontext, width, height, [dialog_button_selection,&leftbutton_rect](auto surface) {
        SDL_BlitSurface(dialog_button_selection, NULL, surface, &leftbutton_rect);
    });

    auto rightbutton_selected_texture = create_texture_from_surface(uicontext, width, height, [dialog_button_selection,&rightbutton_rect](auto surface) {
        SDL_BlitSurface(dialog_button_selection, NULL, surface, &rightbutton_rect);
    });

    auto buttontext_texture = create_texture_from_surface(uicontext, width, height, [&uicontext,&leftbutton_rect,&rightbutton_rect](auto surface) {
        auto font = uicontext.registry.fonts({uicontext.FONT_PROPOTIONAL, 24});
        auto ok_surface = make_shared(TTF_RenderUTF8_Blended(font, "OK", {0,0,0,255}));
        auto cancel_surface = make_shared(TTF_RenderUTF8_Blended(font, "キャンセル", {0,0,0,255}));
        SDL_Rect ok_rect {
            leftbutton_rect.x + leftbutton_rect.w / 2 - ok_surface->w / 2, leftbutton_rect.y + leftbutton_rect.h / 2 - ok_surface->h / 2,
            ok_surface->w, ok_surface->h
        };
        SDL_Rect cancel_rect {
            rightbutton_rect.x + rightbutton_rect.w / 2 - cancel_surface->w / 2, rightbutton_rect.y + rightbutton_rect.h / 2 - cancel_surface->h / 2,
            cancel_surface->w, cancel_surface->h
        };
        SDL_BlitSurface(ok_surface.get(), NULL, surface, &ok_rect);
        SDL_BlitSurface(cancel_surface.get(), NULL, surface, &cancel_rect);
    });

    bool ok = default_value;

    RenderFunc rf(uicontext, [width,height,&window_texture,&buttons_texture,
        &leftbutton_selected_texture,&rightbutton_selected_texture,
        &buttontext_texture,&ok](auto uicontext,bool) {
        SDL_Rect rect = uicontext.center_rect(width, height);
        SDL_RenderCopy(uicontext, window_texture.get(), NULL, &rect);
        SDL_RenderCopy(uicontext, buttons_texture.get(), NULL, &rect);

        blink(leftbutton_selected_texture.get());
        blink(rightbutton_selected_texture.get());
        SDL_RenderCopy(uicontext, ok? leftbutton_selected_texture.get() : rightbutton_selected_texture.get(), NULL, &rect);

        SDL_RenderCopy(uicontext, buttontext_texture.get(), NULL, &rect);
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
        SDL_RenderPresent(uicontext);
    }

    return ok;
}

bool messagebox_okcancel(UIContext& uicontext, const std::string& message, bool default_value/* = true*/, bool caution/* = false*/)
{
    return messagebox_okcancel(uicontext, [&message,caution](auto uicontext){
        auto caution_sign = uicontext.registry.surfaces("caution_sign.png");

        auto message_surface = make_shared(TTF_RenderUTF8_Blended(uicontext.registry.fonts({uicontext.FONT_PROPOTIONAL, 24}), message.c_str(), {0,0,0,255}));

        auto content_width = std::max(message_surface->w, caution_sign->w);
        auto content_height = message_surface->h + (caution? caution_sign->h : 0);

        return with_transparent_surface(content_width, content_height, [message_surface,caution,caution_sign](auto surface) {
            int y = 0;
            if (caution) {
                SDL_Rect rect { (surface->w - caution_sign->w) / 2, y, caution_sign->w, caution_sign->h};
                SDL_BlitSurface(caution_sign, NULL, surface, &rect);
                y += rect.h;
            }
            SDL_Rect rect { (surface->w - message_surface->w) / 2, y, message_surface->w, message_surface->h };
            rect.x = (surface->w - message_surface->w) / 2;
            SDL_BlitSurface(message_surface.get(), NULL, surface, &rect);
        });
    }, default_value);
}

bool messagebox_ok(UIContext& uicontext, std::function<std::shared_ptr<SDL_Surface>(UIContext&)> func)
{
    auto dialog_button = uicontext.registry.surfaces("dialog_button.png");
    auto const& [window_texture,width,height,content_rect,buttonarea_height] = create_window_texture_from_surface(uicontext, [dialog_button,func](auto uicontext) {
        auto message_surface = func(uicontext);

        auto content_width = std::max(message_surface->w, dialog_button->w);
        auto content_height = message_surface->h;

        return with_transparent_surface(content_width, content_height, [message_surface](auto surface) {
            SDL_Rect rect { (surface->w - message_surface->w) / 2, 0, message_surface->w, message_surface->h };
            SDL_BlitSurface(message_surface.get(), NULL, surface, &rect);
        });
    });

     // buttons
    auto dialog_button_selection = uicontext.registry.surfaces("dialog_button_selection.png");
    SDL_Rect button_rect {
        (width - dialog_button->w) / 2,
        content_rect.y + content_rect.h + (buttonarea_height - dialog_button->h) / 2,
        dialog_button->w, dialog_button->h
    };

    auto button_texture = create_texture_from_surface(uicontext, width, height, [dialog_button,&button_rect](auto surface) {
        SDL_BlitSurface(dialog_button, NULL, surface, &button_rect);
    });

    auto button_selected_texture = create_texture_from_surface(uicontext, width, height, [dialog_button_selection,&button_rect](auto surface) {
        SDL_BlitSurface(dialog_button_selection, NULL, surface, &button_rect);
    });

    auto buttontext_texture = create_texture_from_surface(uicontext, width, height, [&uicontext,&button_rect](auto surface) {
        auto font = uicontext.registry.fonts({uicontext.FONT_PROPOTIONAL, 24});
        auto ok_surface = make_shared(TTF_RenderUTF8_Blended(font, "OK", {0,0,0,255}));
        SDL_Rect ok_rect {
            button_rect.x + button_rect.w / 2 - ok_surface->w / 2, button_rect.y + button_rect.h / 2 - ok_surface->h / 2,
            ok_surface->w, ok_surface->h
        };
        SDL_BlitSurface(ok_surface.get(), NULL, surface, &ok_rect);
    });

    bool ok = true;

    RenderFunc rf(uicontext, [width,height,&window_texture,&button_texture,
        &button_selected_texture,
        &buttontext_texture,&ok](auto uicontext,bool) {
        SDL_Rect rect = uicontext.center_rect(width, height);
        SDL_RenderCopy(uicontext, window_texture.get(), NULL, &rect);
        SDL_RenderCopy(uicontext, button_texture.get(), NULL, &rect);

        blink(button_selected_texture.get());
        SDL_RenderCopy(uicontext, button_selected_texture.get(), NULL, &rect);
        SDL_RenderCopy(uicontext, buttontext_texture.get(), NULL, &rect);
        return true;
    });

    while (true) {
        uicontext.render();
        if (!process_event([&ok](auto ev) {
            if (ev.type == SDL_KEYDOWN) {
                if (ev.key.keysym.sym == SDLK_RETURN || ev.key.keysym.sym == SDLK_KP_ENTER) {
                    return false;
                } else if (ev.key.keysym.sym == SDLK_ESCAPE) {
                    ok = false;
                    return false;
                }
            }
            return true;
        })) break;
        SDL_RenderPresent(uicontext);
    }

    return ok;
}

bool messagebox_ok(UIContext& uicontext, const std::string& message, bool caution/* = false*/)
{
    return messagebox_ok(uicontext, [&message,caution](auto uicontext){
        auto caution_sign = uicontext.registry.surfaces("caution_sign.png");

        auto message_surface = make_shared(TTF_RenderUTF8_Blended(uicontext.registry.fonts({uicontext.FONT_PROPOTIONAL, 24}), message.c_str(), {0,0,0,255}));

        auto content_width = std::max(message_surface->w, caution_sign->w);
        auto content_height = message_surface->h + (caution? caution_sign->h : 0);

        return with_transparent_surface(content_width, content_height, [message_surface,caution,caution_sign](auto surface) {
            int y = 0;
            if (caution) {
                SDL_Rect rect { (surface->w - caution_sign->w) / 2, y, caution_sign->w, caution_sign->h};
                SDL_BlitSurface(caution_sign, NULL, surface, &rect);
                y += rect.h;
            }
            SDL_Rect rect { (surface->w - message_surface->w) / 2, y, message_surface->w, message_surface->h };
            rect.x = (surface->w - message_surface->w) / 2;
            SDL_BlitSurface(message_surface.get(), NULL, surface, &rect);
        });
    });
}

int messagebox_select(UIContext& uicontext, std::function<std::shared_ptr<SDL_Surface>(UIContext&)> message_func, std::function<std::shared_ptr<SDL_Surface>()> item_func)
{
    
}

static int _main(int,char*[])
{
    const auto width = 1024, height = 768;
    std::filesystem::path theme_dir("./default_theme");
    SDL_Init(SDL_INIT_VIDEO);
    TTF_Init();

    {
        auto window = make_shared(SDL_CreateWindow("messagebox_main",SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,width,height,SDL_WINDOW_SHOWN));
        auto renderer = make_shared(SDL_CreateRenderer(window.get(), -1, SDL_RENDERER_PRESENTVSYNC));
        UIContext uicontext(renderer, theme_dir);

        auto font =  uicontext.registry.fonts({uicontext.FONT_PROPOTIONAL, 32});

        auto texture = create_texture_from_surface(uicontext, [font]() {
            return make_shared(TTF_RenderUTF8_Blended(font, __FILE__, {255,255,255,255}));
        });

        RenderFunc rf(uicontext, [texture](auto renderer, bool) {
            SDL_SetRenderDrawColor(renderer, 0, 0, 0, 0);
            SDL_RenderClear(renderer);
            auto const& [ t, w, h ] = texture;
            SDL_Rect rect = {0, 0, w, h};
            SDL_RenderCopy(renderer, t.get(), NULL, &rect);
            return true;
        });

        messagebox_ok(uicontext, "メッセージボックス(OK)", false);
        messagebox_okcancel(uicontext, "メッセージボックス(OK/CANCEL)", false, false);
        messagebox_ok(uicontext, "メッセージボックス(OK)", true);
        messagebox_okcancel(uicontext, "メッセージボックス(OK/CANCEL)", false, true);
    }

    TTF_Quit();
    SDL_Quit();

    return 0;
}

#ifdef __MAIN_MODULE__
int main(int argc, char* argv[]) { return _main(argc, argv); }
#endif

