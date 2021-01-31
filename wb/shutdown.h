#include "uicontext.h"

class Shutdown {
    UIContext& uicontext;
    struct {
        std::shared_ptr<SDL_Texture> notselected, selected;
        std::shared_ptr<SDL_Texture> shutdown, reboot;
    } textures;
    int item_width, item_height;
    std::pair<int,int> shutdown_text_size, reboot_text_size;
    int selected = -1;
public:
    Shutdown(UIContext& _uicontext) : uicontext(_uicontext) {;}
    void draw(SDL_Renderer* renderer = NULL, bool focus = false);
    void on_select();
    void on_deselect();
    bool on_enter();
};