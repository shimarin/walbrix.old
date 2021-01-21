#include <sys/utsname.h>
#include "wb.h"

std::pair<uint16_t, uint16_t> measure_text_size(const char* text)
{
  uint16_t x = 0, width = 0;
  uint16_t height = 1;
  const char* pt = text;
  while (*pt) {
    if (*pt == '\n') {
      if (x > width) width = x;
      x = 0;
      height++;
      pt++;
      continue;
    }
    int len = tb_utf8_char_length(*pt);
    if (len == TB_EOF) break;
    uint32_t ch;
    tb_utf8_char_to_unicode(&ch, pt);
    int w = wcwidth(ch);
    if (w < 1) w = 1;
    x += w;
    pt += len;
  }
  if (x > width) width = x;
  return std::make_pair(width, height);
}

std::pair<uint16_t, uint16_t> resize(const std::pair<uint16_t, uint16_t>& size, int16_t width, int16_t height)
{
  return std::make_pair(size.first + width, size.second + height);
}

void TbAbstractWindow::draw_text(int16_t x, int16_t y, const char* text, uint16_t fg/* = TB_DEFAULT*/, uint16_t bg/* = TB_DEFAULT*/) {
  const char* pt = text;
  while (*pt) {
    if (*pt == '\n') {
      x = 0;
      y ++;
      pt++;
      continue;
    }
    int len = tb_utf8_char_length(*pt);
    if (len == TB_EOF) break;
    uint32_t ch;
    tb_utf8_char_to_unicode(&ch, pt);
    int w = wcwidth(ch);
    if (w < 1) w = 1;
    if (x + w > _width) {
      y ++;
      x = 0;
    }
    change_cell(x, y, ch, fg, bg);
    x += w;
    pt += len;
  }
}

void TbAbstractWindow::draw_text_center(int16_t y, const char* text, uint16_t fg/* = TB_DEFAULT*/, uint16_t bg/* = TB_DEFAULT*/) {
  int16_t x = _width / 2 - measure_text_size(text).first / 2;
  draw_text(x, y, text, fg, bg);
}

void TbAbstractWindow::draw(TbAbstractWindow& dst, int16_t x, int16_t y, bool border/*=true*/)
{
  draw_self();
  for (uint16_t yi = 0; yi < _height; yi++) {
    for (uint16_t xi = 0; xi < _width; xi++){
      if (x + xi < 0 || x + xi >= dst.width() || y + yi < 0 || y + yi >= dst.height()) continue;
      dst.put_cell(x + xi, y + yi, cell_at(xi, yi));
    }
  }
  dst.change_cell(x - 1, y - 1, 0x250c); // ┌
  dst.change_cell(x + _width, y - 1, 0x2510); // 	┐
  dst.change_cell(x - 1, y + _height, 0x2514); // └
  dst.change_cell(x + _width, y + _height, 0x2518); // 	┘

  if (border) {
    for (uint16_t xi = 0 ; xi < _width; xi++) {
     // ─
      dst.change_cell(x + xi, y - 1, 0x2500);
      dst.change_cell(x + xi, y + _height, 0x2500);
    }

    for (uint16_t yi = 0; yi < _height; yi++) {
      // │
      dst.change_cell(x - 1, y + yi, 0x2502);
      dst.change_cell(x + _width, y + yi, 0x2502);
    }

    if (_caption) {
      const auto& caption = _caption.value();
      dst.draw_text(x, y - 1, caption.c_str(), TB_CYAN|TB_REVERSE, TB_REVERSE);
    }
  }
}

int ui_old(bool login/* = false*/)
{
  /* TODO: remove after -
  utsname uname_buf;
  std::string version = uname(&uname_buf) == 0? uname_buf.release : "";
  */
  std::pair<bool, std::optional<int> > result;
  {
    Termbox termbox;
    TbRootWindow root = termbox.root();
    TbMenu<int> menu;
    menu.add_item(1, "シャットダウン");
    menu.add_item(2, "再起動");
    if (login) {
      menu.add_item(3, "Linuxコンソール");
    }
    menu.add_item(std::nullopt, "メニューを終了[ESC]");
    TbWindow window(menu.get_size(), (std::string)"Walbrix"/* + version*/);
    tb_event event;
    event.type = 0;
    menu.selection(0);
    while (!(result = menu.process_event(event)).first) {
      menu.draw(window);
      window.draw_center(root);
      termbox.present();
      termbox.poll_event(&event);
    }
  }

  if (!result.second) return 0;

  switch (result.second.value()) {
  case 1:
    execl("/sbin/poweroff", "/sbin/poweroff", NULL);
    break;
  case 2:
    execl("/sbin/reboot", "/sbin/reboot", NULL);
    break;
  case 3:
    return 9;
  default:
    RUNTIME_ERROR("menu");
  }
  return 0;
}
