#include <SDL2/SDL.h>
#include <memory>
#include <functional>

#include "uicontext.h"

bool messagebox_okcancel(UIContext& uicontext, const std::string& message, bool default_value = true, bool caution = false);