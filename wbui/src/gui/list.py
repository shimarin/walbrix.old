# -*- coding:utf-8 -*-

"""
リストボックスを実装するモジュール
"""

import copy

import pygame
import gui.util

class List(gui.Window, gui.EventHandler):
    """
    リストボックスを実装するクラス。他ウィンドウの子エンティティとして表示でき、かつイベントハンドラとしてイベントループに渡されることによってユーザとの対話処理をする。
    """
    def __init__(self, size, items=None):
        """
        コンストラクタ
        size: (幅, 高さ)
        items: ListItem オブジェクトのリスト。Noneの場合アイテムのないリストボックスが作成される。リストボックスのアイテムは addItemメソッドで追加できる。
        """
        gui.Window.__init__(self, size)
        gui.EventHandler.__init__(self)
        self.items = items if items != None else []
        self.bgcolor = None
        self.bgimage = None
        self.selected = None if len(self.items) == 0 else 0
        self.previously_selected = None
        self.eventHandler = None
        self.keep_showing_cursor = False
        self.offset = 0
        self.margin_top = 0
        self.item_pos = None

    def setBgColor(self, bgcolor):
        """
        リストボックスの背景色をセットする。
        bgcolor: pygame.Color オブジェクト又は RGBAのタプル。Noneの場合背景は描画されない
        """
        self.bgcolor = bgcolor

    def setBgImage(self, bgimage):
        self.bgimage = bgimage

    def setMarginTop(self, margin_top):
        self.margin_top = margin_top

    def getMarginTop(self):
        return self.margin_top

    def keepShowingCursor(self):
        """
        このリストボックスがアクティブでない(現在のイベントループを処理しているイベントハンドラがこのリストボックスでない)場合でもカーソルを表示し続けるよう指示する。
        """
        self.keep_showing_cursor = True

    def setEventHandler(self, eventHandler): # ListEventHandler
        """
        リストボックスイベントのハンドラをセットする。ユーザー操作により選択が変わった際に何らかの処理をしたい場合などに使用される。
        eventHandler: ListEventHandler オブジェクト。Noneを指定するとハンドラはアンセットされる
        """
        self.eventHandler = eventHandler

    def addItem(self, item):
        """
        リストボックスにアイテムを追加する
        item: ListItem オブジェクト
        """
        self.item_pos = None
        self.items.append(item)
        if self.selected == None: self._set_selected_index(0)

    def addItems(self, items):
        """
        リストボックスにアイテムを複数追加する
        items: ListItem オブジェクトのリスト
        """
        self.item_pos = None
        self.items += items
        if self.selected == None: self._set_selected_index(0)

    def getItems(self):
        return copy.copy(self.items)
    
    def clearItem(self):
        """
        リストボックスから全てのアイテムを取り除く
        """
        self.item_pos = None
        self.items = []
        self._set_selected_index(None)
        self.offset = 0

    def getNumItems(self):
        """
        リストボックスの持つアイテム数を得る
        return value: アイテム数
        """
        return len(self.items)

    def getTotalItemHeight(self):
        """
        全てのアイテムの高さを合計した値を返す
        return value: 高さの合計
        """
        return sum(map(lambda x:x.getHeight(), self.items))

    def getContentWidth(self):
        """
        全てのアイテムのコンテンツを余すことなく収めるのに要求される横幅を得る
        return value: 必要な横幅
        """
        return max(map(lambda x:x.getContentWidth(), self.items))

    def getSelected(self):
        """
        現在選択されているアイテムを返す
        return value: ListItem オブジェクト。アイテムが選択されていない場合は None
        """
        return self.items[self.selected]

    def getSelectedIndex(self):
        """
        現在選択されているアイテムのインデックスを返す。
        return value: 選択されているアイテムのインデックス。一番上のアイテムが 0
        """
        return self.selected

    def getItemPos(self):
        """
        直接呼び出したりオーバーライドされるべきでない
        """
        if self.item_pos != None: return self.item_pos
        self.item_pos = []
        y = self.margin_top
        for item in self.items:
            self.item_pos.append(y)
            y += item.getHeight()
        return self.item_pos

    def calculateItemPos(self, selected = None):
        """
        直接呼び出したりオーバーライドされるべきでない
        """
        if selected == None: selected = self.selected
        if selected == None: return None
        return self.getItemPos()[selected] - self.offset

    def adjustOffset(self):
        """
        直接呼び出したりオーバーライドされるべきでない
        """
        if self.selected == None: return
        y = self.calculateItemPos(self.selected)
        if y < self.margin_top:
            self.offset -= -y
            return
        #else
        bottom = y + self.items[self.selected].getHeight()
        if bottom > self.getHeight():
            self.offset += bottom - self.getHeight()

    def drawCursor(self, surface, selected, item, y, active):
        gui.util.render_cursor(surface, (0, y, surface.get_width(), item.getHeight()), active)

    def paint(self, surface):
        """
        直接呼び出したりオーバーライドされるべきでない
        """
        if self.bgcolor is not None: surface.fill(self.bgcolor)
        if self.bgimage is not None: surface.blit(self.bgimage, (0, 0))
        item_pos = self.getItemPos()

        if self.selected != None:
            y = self.calculateItemPos()
            if self.previously_selected != None:
                y = gui.util.get_moving_value_by_time((self.calculateItemPos(self.previously_selected[0]), self.calculateItemPos(self.selected)), self.previously_selected[1], 200)
            width = self.getWidth()
            height = self.items[self.selected].getHeight()
            active_level = self.getActiveLevel() # 0=no 1=yesinpreveventloop 2=yes
            if self.isActive() or self.keep_showing_cursor:
                self.drawCursor(surface, self.selected, self.items[self.selected], y, self.getActiveLevel() == 2)
        i = 0
        for item in self.items:
            item.paint(surface, item_pos[i] - self.offset)
            i += 1

        # カーソルの上下矢印描画
        if self.isActive() and self.selected != None and gui.util.get_cycling_bool_by_time(1500):
            if self.isAbleToGoUp():
                surface.blit(gui.res.list_up_arrow, gui.util.center_to_lefttop(gui.res.list_up_arrow, (width / 2, y)))
            if self.isAbleToGoDown():
                surface.blit(gui.res.list_down_arrow, gui.util.center_to_lefttop(gui.res.list_down_arrow, (width / 2, y + height - 1)))

    def leaveEventLoop(self):
        """
        直接呼び出したりオーバーライドされるべきでない
        """
        self.keep_showing_cursor = False

    def select(self):
        """
        直接呼び出したりオーバーライドされるべきでない
        """
        self.setResult(self.selected)
        return True

    def cancel(self):
        """
        直接呼び出したりオーバーライドされるべきでない
        """
        self.setResult(None)
        return True
    
    def isAbleToGoUp(self):
        """
        直接呼び出したりオーバーライドされるべきでない
        """
        if len(self.items) == 0: return False
        if self.selected != None and self.selected <= 0: return False

        selected = self.selected if self.selected != None else len(self.items) # 暫定
        return any(not isinstance(x, Separator) for x in self.items[:selected])

    def _set_selected_index(self, new_index):
        if self.selected == new_index: return
        self.selected = new_index
        if self.eventHandler is not None: self.eventHandler.onChange(self)        
    def setSelectedIndex(self, new_index):
        '''
        クライアント契機での選択変更。イベントは発生させないしトランジション効果も適用しない
        '''
        if new_index >= len(self.items): new_index = len(self.items) - 1
        if new_index < 0: new_index = None
        self.previously_selected = None
        self.selected = new_index

    def up(self):
        """
        カーソルを(可能なら)上に移動する
        """
        if not self.isAbleToGoUp(): return False
        selected = self.selected - 1 if self.selected != None else len(self.items) - 1 # 暫定
        while isinstance(self.items[selected], Separator):
            selected -= 1
                   
        self.previously_selected = (self.selected, pygame.time.get_ticks())
        self._set_selected_index(selected)
        self.adjustOffset()
        return False

    def isAbleToGoDown(self):
        """
        直接呼び出したりオーバーライドされるべきでない
        """
        if len(self.items) == 0: return False
        if self.selected != None and self.selected >= len(self.items) - 1: return False
        selected = self.selected if self.selected != None else -1
        return any(not isinstance(x, Separator) for x in self.items[selected + 1:])
    
    def down(self):
        """
        カーソルを(可能なら)下に移動する
        """
        if not self.isAbleToGoDown(): return False

        selected = self.selected + 1 if self.selected != None else 0
        while isinstance(self.items[selected], Separator):
            selected += 1

        self.previously_selected = (self.selected, pygame.time.get_ticks())
        self._set_selected_index(selected)
        self.adjustOffset()
        return False

class ListEventHandler:
    """
    リストボックス上で起こったイベントを処理するためのハンドラ
    List クラスの setEventHandler メソッドでセットされる
    """
    def onChange(self, target):
        """
        ユーザー操作によりリストの選択対象が変化したときに呼び出される
        target: 変化の起こった List オブジェクト
        """
        pass

class ListItem:
    """
    リストボックスに格納されるアイテムを表現する抽象クラス。
    """
    def __init__(self, height):
        """
        コンストラクタ
        height: このアイテムの高さ
        """
        self.height = height
    
    def getHeight(self):
        """
        このアイテムの高さを得る
        return value: アイテムの高さ
        """
        return self.height

    def getContentWidth(self):
        """
        このアイテムのコンテンツを余すことなく収めるのに要求される横幅を得る
        return value: 必要な横幅
        """
        return 0

    def paint(self, surface, y):
        """
        アイテムの描画が必要な際に呼び出される。
        surface: 描画対象の pygame.Surface
        y: アイテムを描画開始すべき y座標
        """
        pass

class Separator(ListItem):
    pass

class Nested:
    def __init__(self, sublist):
        self.sublist = sublist
    def getSublist(self):
        return self.sublist

class TextListItem(ListItem):
    """
    テキストのリストアイテム
    """
    def __init__(self, text, font, color = None, height = None, data = None):
        """
        コンストラクタ
        text: アイテムとして表示されるテキスト
        font: テキスト表示に用いられる pygame.font.Font
        color: テキストの色。pygame.Color または RGBAのタプル。Noneの場合 gui.res.color_textが用いられる
        height: アイテムの高さ。None指定時はフォントとテキストから自動で決定
        data: このアイテムに付随させる任意のオブジェクト。不要な場合 None
        """
        if color == None: color = gui.res.color_text
        if height == None: height = font.size(text)[1]
        ListItem.__init__(self, height)
        self.font = font
        self.text = text
        self.color = color
        self.data = data
        self.text_cache = None

    def getText(self):
        """
        アイテムのテキストを取得する
        return value: アイテムとして表示されるテキスト
        """
        return self.text

    def renderItemText(self):
        return self.font.render(self.text, True, self.color)

    def getRenderedItemText(self):
        if self.text_cache == None:
            self.text_cache = self.renderItemText()
        return self.text_cache

    def getFont(self):
        """
        テキストの描画に使用されるフォントを得る
        return value: 描画に使用される pygame.font.Font オブジェクト
        """
        return self.font

    def getContentWidth(self):
        """
        このアイテムのコンテンツを余すことなく収めるのに要求される横幅を得る
        return value: 必要な横幅
        """
        return self.font.size(self.text)[0]

    def getColor(self):
        """
        テキストの色を取得する
        return value: テキストの色
        """
        return self.color

    def getData(self):
        """
        このアイテムに付随するオブジェクトを得る
        return value: 付随するオブジェクト
        """
        return self.data

    def getHeight(self):
        """
        アイテムの高さを得る
        return value: 高さ
        """
        return self.height

    def paint(self, surface, y):
        """
        アイテムの描画を行う。直接呼び出すべきではない。
        """
        text = self.getRenderedItemText()
        surface.blit(text, (0, y + (self.getHeight() - text.get_height()) / 2))

class CenteredTextListItem(TextListItem):
    """
    中央寄せテキストのリストアイテム
    """
    def paint(self, surface, y):
        """
        中央寄せでアイテムの描画を行う。直接呼び出すべきでは内。
        """
        text = self.getRenderedItemText()
        surface.blit(text, ((surface.get_width() - text.get_width()) / 2, y + (self.getHeight() - text.get_height()) / 2))

class LabelValueItem(TextListItem):
    """
    ラベル-値のリストアイテム
    """
    def __init__(self, label, value, font, label_color = None, value_color = None, height = None, data = None):
        """
        コンストラクタ
        label: ラベルのテキスト
        value: 値
        font: テキストの描画に使用するフォント
        label_color: ラベルの色。None の場合は gui.res.color_text
        value_color: 値の色。None の場合は gui.res.color_text
        height: アイテムの高さ。None指定時はフォントとラベルテキストから自動で決定
        data: このアイテムに付随させる任意のオブジェクト。不要な場合 None
        """
        TextListItem.__init__(self, label, font, label_color, height, data)
        self.value = str(value)
        self.value_color = value_color if value_color != None else gui.res.color_text
        self.value_text_cache = None

    def getContentWidth(self):
        """
        このアイテムのコンテンツを余すことなく収めるのに要求される横幅を得る
        return value: 必要な横幅
        """
        return self.getFont().size(self.getText())[0] + self.getFont().size(self.value)[0] + 10

    def setValue(self, value):
        """
        このアイテムの値を変更する
        value: 新しい値のテキスト
        """
        self.value = value
        self.value_text_cache = None

    def setValueColor(self, value_color):
        """
        このアイテムの値テキストの色を変更する
        value_color: 新しい色
        """
        self.value_color = value_color
        self.value_text_cache = None

    def paint(self, surface, y):
        """
        アイテムの描画を行う。直接呼び出すべきではない。
        """
        label = self.getRenderedItemText()
        if self.value_text_cache == None:
            self.value_text_cache = self.getFont().render(self.value, True, self.value_color)
        value = self.value_text_cache
        surface.blit(label, (0, y + (self.getHeight() - label.get_height()) / 2))
        surface.blit(value, (surface.get_width() - value.get_width(), y + (self.getHeight() - value.get_height()) / 2))

class IconTextListItem(TextListItem):
    """
    アイコンとテキストの並んだリストアイテムを表現するクラス
    """
    def __init__(self, icon, text, font, color = None, height = None, data = None):
        """
        コンストラクタ
        icon: アイコンとして表示される pygame.Surface オブジェクト
        text: アイテムとして表示されるテキスト
        font: テキスト表示に用いられる pygame.font.Font
        color: テキストの色。pygame.Color または RGBAのタプル。Noneの場合 gui.res.color_textが用いられる
        height: アイテムの高さ。None指定時はフォントサイズとアイコンサイズから自動で決定
        data: このアイテムに付随させる任意のオブジェクト。不要な場合 None
        """
        if height == None: height = max(icon.get_height(), font.get_height())
        TextListItem.__init__(self, text, font, color, height, data)
        self.icon = icon

    def getContentWidth(self):
        """
        このアイテムのコンテンツを余すことなく収めるのに要求される横幅を得る
        return value: 必要な横幅
        """
        return self.icon.get_width() + self.getFont().size(self.getText())[0] + 1 # shadowの分

    def renderItemText(self):
        return gui.util.render_font_with_shadow(self.getFont(), self.getText())

    def paint(self, surface, y):
        """
        アイテムの描画を行う。直接呼び出すべきではない。
        """
        icon_height = self.icon.get_height()
        surface.blit(self.icon, (0, y + (self.getHeight() - icon_height) / 2))
        x = self.icon.get_width()
        text = self.getRenderedItemText()
        surface.blit(text, (x, y + (self.getHeight() - text.get_height()) / 2))
