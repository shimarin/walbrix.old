#include "uicontext.h"

class Installer {
    UIContext& uicontext;
    int width;

    std::vector<std::tuple<std::string/*name*/,uint64_t/*size*/,uint16_t/*log_sec*/,std::shared_ptr<SDL_Texture>,int/*y*/,int/*h*/,std::string/*details*/> > options;

    void load_options();
public:
    Installer(UIContext& _uicontext) : uicontext(_uicontext), width(uicontext.width - uicontext.mainmenu_width) {;}

    void on_select();
    void on_deselect();
    void draw(SDL_Renderer* renderer = NULL);
    bool on_enter();
};

int install_cmdline(const std::vector<std::string>& args);