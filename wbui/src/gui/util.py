# -*- coding:utf-8 -*-
'''
GUI用のユーティリティ

Created on 2011/05/01

@author: shimarin
'''
import pygame
import gui
import math

def render_font_with_shadow(font, text, color=None, shadow_color = None):
    """
    シャドウ付きでテキストをレンダリングする
    font: テキストのレンダリングに使用する pygame.font.Font
    text: レンダリングするテキスト
    color: テキストの色。 Noneの場合は gui.res.color_text
    shadow_color: シャドウの色。 Noneの場合は gui.res.color_text_shadow
    return value: レンダリングされた pygame.Surface
    """
    if color == None: color = gui.res.color_text
    if shadow_color == None: shadow_color = gui.res.color_text_shadow
    shadow = font.render(text, True, shadow_color)
    real = font.render(text, True, color)
    canvas = pygame.Surface(real.get_size(), pygame.SRCALPHA, 32)
    canvas.blit(shadow, (1, 1))
    canvas.blit(real, (0, 0))
    return canvas

def render_cursor(surface, rect, blink, color=None):
    """
    (リストボックスなどの)カーソルをレンダリングする
    surface: レンダリング対象の pygame.Surface
    rect: カーソルの矩形
    blink: カーソルをブリンクさせる(時間によってアルファ値を変化させる)場合は True
    color: カーソルの色。 Noneの場合 gui.res.color_cursorを使用
    """
    if color == None: color = gui.res.color_cursor
    alpha = 64
    if blink: alpha = get_cycling_value_by_time((16,128), 2000)
    canvas = pygame.Surface((rect[2],rect[3]), pygame.SRCALPHA, 32)
    canvas.fill((color[0],color[1],color[2],alpha))
    surface.blit(canvas, (rect[0],rect[1]))

def render_font_with_wordwrap(font, maxWidth, text, color=None):
    """
    折り返し付きでテキストをレンダリングする
    font: テキストのレンダリングに使用する pygame.font.Font
    maxWidth: テキストの最大幅
    text: レンダリングするテキスト
    color: テキストの色。 Noneの場合は gui.res.color_text
    return value: レンダリングされた pygame.Surface
    """
    if color == None: color = gui.res.color_text
    fullsize = font.size(text)
    if fullsize[0] <= maxWidth:
        return font.render(text, True, color)
    estimated_length = len(text) * maxWidth * 3 / fullsize[0] / 2
    head = 0
    tail = estimated_length
    rendered = []

    while head < tail:
        while font.size(text[head:tail])[0] > maxWidth:
            tail -= 1
            if head == tail:
                break
        rendered.append(font.render(text[head:tail], True, color))
        head = tail
        tail = min(len(text), head + estimated_length)

    height = 0
    for r in rendered:
        height += r.get_height()

    box = pygame.Surface((maxWidth, height), pygame.SRCALPHA, 32)
    y = 0
    for r in rendered:
        box.blit(r, (0, y))
        y += r.get_height()
    return box

def draw_round_rect(surface, color, rect, width, xr, yr):
    """
    角の丸い矩形を描画する
    surface: 描画対象の pygame.Surface
    color: 色。width=0の場合塗りつぶしの色、それ以外の場合線の色
    rect: 矩形。pygame.Rect又は (x, y, w, h )
    width: 線の太さ。0の場合線は描画されず矩形はcolorで塗りつぶされる
    xr: 角の径(x)
    yr: 角の径(y)
    """
    if isinstance(rect, tuple): rect = pygame.Rect(rect[0], rect[1], rect[2], rect[3])
    
    clip = surface.get_clip()
    
    # left and right
    surface.set_clip(clip.clip(rect.inflate(0, -yr*2)))
    pygame.draw.rect(surface, color, rect.inflate(1-width,0), width)

    # top and bottom
    surface.set_clip(clip.clip(rect.inflate(-xr*2, 0)))
    pygame.draw.rect(surface, color, rect.inflate(0,1-width), width)

    # top left corner
    surface.set_clip(clip.clip(rect.left, rect.top, xr, yr))
    pygame.draw.ellipse(surface, color, pygame.Rect(rect.left, rect.top, 2*xr, 2*yr), width)

    # top right corner
    surface.set_clip(clip.clip(rect.right-xr, rect.top, xr, yr))
    pygame.draw.ellipse(surface, color, pygame.Rect(rect.right-2*xr, rect.top, 2*xr, 2*yr), width)

    # bottom left
    surface.set_clip(clip.clip(rect.left, rect.bottom-yr, xr, yr))
    pygame.draw.ellipse(surface, color, pygame.Rect(rect.left, rect.bottom-2*yr, 2*xr, 2*yr), width)

    # bottom right
    surface.set_clip(clip.clip(rect.right-xr, rect.bottom-yr, xr, yr))
    pygame.draw.ellipse(surface, color, pygame.Rect(rect.right-2*xr, rect.bottom-2*yr, 2*xr, 2*yr), width)

    surface.set_clip(clip)

def draw_filled_round_rect_with_frame(surface, bg_color, frame_color, rect, frame_width, xr, yr):
    """
    角の丸い塗りつぶしの矩形を枠付きで描画する
    surface: 描画対象の pygame.Surface
    bg_color: 塗りつぶしの色
    frame_color: 枠の色
    rect: 矩形。pygame.Rect又は (x, y, w, h )
    frame_width: 枠の太さ
    xr: 角の径(x)
    yr: 角の径(y)
    """
    draw_round_rect(surface, bg_color, rect, 0, xr,yr)
    draw_round_rect(surface, frame_color, rect, frame_width, xr, yr)

def center_to_lefttop(surface, coord):
    """
    与えられたサーフェスを中心に表示するための座標計算
    surface: 中心に表示したい pygame.Surface
    coord: 中心座標
    return value: そのサーフェスをblitすべき 左上隅座標
    """
    x = coord[0]
    y = coord[1]
    return (x - surface.get_width() / 2, y - surface.get_height() / 2)

def get_cycling_value_by_time(range, cycle):
    """
    時間によって循環する値を得る。値の算出にはsin関数が用いられる。
    range: (下限値, 上限値)
    cycle: 周期(ms)
    return value: 下限値 <= n <= 上限値
    """
    min = range[0]
    max = range[1]
    distance = float(max - min)
    time = pygame.time.get_ticks() % cycle
    time = float(time) / cycle
    v = math.sin(time * math.pi)
    return min + distance / 2 + distance / 2 * v

def get_moving_value_by_time(range, time_start, time_max):
    """
    時間によって進捗する値を得る。値の算出には sin関数が用いられる(値域 sin(0)-sin(pi/2))
    range: (開始値, 終了値)
    time_start: 開始時刻(ms) pygame.time.get_ticks() などで得た値を用いる
    time_max: 終了地に到達する経過時間(ms)
    return value: 開始値 <= n <= 終了値
    """
    min = range[0]
    max = range[1]
    current_time = pygame.time.get_ticks()
    if time_max + time_start <= current_time: return max
    distance = float(max - min)
    time = float(current_time - time_start) / time_max
    v = math.sin(time * math.pi / 2)
    return min + distance * v

def get_cycling_bool_by_time(cycle):
    """
    時間によって循環する True/False値を得る
    cycle: 周期(ms)
    return value: True又は False
    """
    if cycle == 0: return False
    if cycle == 1: return True
    time = pygame.time.get_ticks() % cycle
    return time < cycle / 2

class Tick:
    """
    タイマ的な目的に使用するクラス
    """
    def __init__(self, interval):
        self.previous_tick = pygame.time.get_ticks()
        self.interval = interval
    def exceeded(self):
        return self.previous_tick + self.interval > pygame.time.get_ticks()
    def reset(self):
        self.previous_tick = pygame.time.get_ticks()
