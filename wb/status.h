#include "uicontext.h"

class Status {
    UIContext& uicontext;
    std::shared_ptr<SDL_Texture> content;
    int width, height;
public:
    Status(UIContext& _uicontext);

    void draw();
    void on_select();
    void on_deselect();
};
