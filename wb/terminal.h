#include <vterm.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>

class Terminal {
    template <typename T> class Matrix {
        T* buf;
        int rows, cols;
    public:
        Matrix(int _rows, int _cols) : rows(_rows), cols(_cols) {
            buf = new T[cols * rows];
        }
        ~Matrix() {
            delete buf;
        }
        void fill(const T& by) {
            for (int row = 0; row < rows; row++) {
                for (int col = 0; col < cols; col++) {
                    buf[cols * row + col] = by;
                }
            }
        }
        T& operator()(int row, int col) {
            if (row < 0 || col < 0 || row >= rows || col >= cols) throw std::runtime_error("invalid position");
            //else
            return buf[cols * row + col];
        }
        int getRows() const { return rows; }
        int getCols() const { return cols; }
    };

    VTerm* vterm;
    VTermScreen* screen;
    SDL_Surface* surface = NULL;
    SDL_Texture* texture = NULL;
    Matrix<unsigned char> matrix;
    TTF_Font* font;
    int font_width;
    int font_height;
    int fd;
    bool ringing = false;

    const VTermScreenCallbacks screen_callbacks = {
        damage,
        moverect,
        movecursor,
        settermprop,
        bell,
        resize,
        sb_pushline,
        sb_popline
    };

    VTermPos cursor_pos;
public:
    Terminal(int _fd, int _rows, int _cols, TTF_Font* _font);
    ~Terminal();

    void invalidateTexture();

    void keyboard_unichar(char c, VTermModifier mod);
    void keyboard_key(VTermKey key, VTermModifier mod);
    void input_write(const char* bytes, size_t len);
    int damage(int start_row, int start_col, int end_row, int end_col);
    int moverect(VTermRect dest, VTermRect src);
    int movecursor(VTermPos pos, VTermPos oldpos, int visible);
    int settermprop(VTermProp prop, VTermValue *val);
    int bell();
    int resize(int rows, int cols);
    int sb_pushline(int cols, const VTermScreenCell *cells);
    int sb_popline(int cols, VTermScreenCell *cells);
    void render(SDL_Renderer* renderer, const SDL_Rect& window_rect);

    void processEvent(const SDL_Event& ev);

    bool processInput(); // true = stream is alive, false = EOF detected

    static void output_callback(const char* s, size_t len, void* user);
    static int damage(VTermRect rect, void *user);
    static int moverect(VTermRect dest, VTermRect src, void *user);
    static int movecursor(VTermPos pos, VTermPos oldpos, int visible, void *user);
    static int settermprop(VTermProp prop, VTermValue *val, void *user);
    static int bell(void *user);
    static int resize(int rows, int cols, void *user);
    static int sb_pushline(int cols, const VTermScreenCell *cells, void *user);
    static int sb_popline(int cols, VTermScreenCell *cells, void *user);
};
