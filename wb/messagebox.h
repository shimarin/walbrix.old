#include <SDL2/SDL.h>
#include <memory>
#include <functional>

#include "uicontext.h"

bool messagebox_ok(UIContext& uicontext, std::function<std::shared_ptr<SDL_Surface>(UIContext&)> func);
bool messagebox_ok(UIContext& uicontext, const std::string& message, bool caution = false);
bool messagebox_okcancel(UIContext& uicontext, std::function<std::shared_ptr<SDL_Surface>()> func, bool default_value = true);
bool messagebox_okcancel(UIContext& uicontext, const std::string& message, bool default_value = true, bool caution = false);