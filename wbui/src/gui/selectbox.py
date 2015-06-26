# -*- coding:utf-8 -*-
'''
リストからアイテムを選択するダイアログボックスを実装するモジュール

Created on 2011/05/01

@author: shimarin
'''

import gui
import gui.util
import gui.list

class SelectBox(gui.Window):
    """
    リストからアイテムを選択するダイアログボックスを表現するクラス
    """
    def __init__(self, text, options, bgcolor=None):
        """
        コンストラクタ
        text: ダイアログに表示するメッセージ
        options: 選択肢 {"id":選択肢のID, "label":選択肢のテキスト} のリスト。
        bgcolor: ダイアログの背景色。Noneの場合 gui.res.color_dialog_positive
        """
        if bgcolor == None: bgcolor = gui.res.color_dialog_positive
        textImg = gui.util.render_font_with_wordwrap(gui.res.font_messagebox, 580, text, gui.res.color_text)
        maxWidth = textImg.get_width()
        optionsHeight = 0
        optionfont = gui.res.font_select_option
        self.options = {}
        for i in range(0,len(options)):
            option = options[i]
            self.options[i] = option["id"] if "id" in option else None
            text = option["label"]
            size = optionfont.size(text)
            option["height"] = size[1]
            optionsHeight += size[1]
            if maxWidth < size[0]: maxWidth = size[0]
        if maxWidth > 580: maxWidth = 580
        if optionsHeight > 340: optionsHeight = 340
        gui.Window.__init__(self, (maxWidth + 10, textImg.get_height() + optionsHeight + 10))
        
        self.bgcolor = bgcolor
        text = gui.Bitmap(textImg)
        self.list = gui.list.List((maxWidth, optionsHeight))
        for i in range(0,len(options)):
            option = options[i]
            self.list.addItem(gui.list.TextListItem(option["label"], optionfont, None if "id" in option else (96, 96, 96), option["height"]))
        
        self.addChild("text", text, (5, 5))
        self.addChild("list", self.list, (5,5 + textImg.get_height()))

    def execute(self, desktop):
        """
        このダイアログを実行する
        desktop: ダイアログを実行する gui.DesktopWindow
        return value: 選択されたアイテムのID
        """
        with desktop.openDialog(self):
            while True:
                result = gui.eventLoop(self.list)
                if result == None or self.options[self.list.getSelectedIndex()] != None: break
        return self.options[self.list.getSelectedIndex()] if result is not None else None
    
    def paint(self, surface):
        """
        ダイアログの描画。直接呼び出すべきではない。
        """
        gui.util.draw_filled_round_rect_with_frame(surface, self.bgcolor, (255,255,255), (0, 1, self.getWidth(), self.getHeight()), 3, 5, 5)

def execute(text, options, bgcolor = None):
    """
    リストからアイテムを選択するダイアログボックスを実行する。
    text: ダイアログに表示するメッセージ
    options: 選択肢 {"id":選択肢のID, "label":選択肢のテキスト} のリスト。
    bgcolor: ダイアログの背景色。Noneの場合 gui.res.color_dialog_positive
    """
    selectBox = SelectBox(text, options, bgcolor)
    return selectBox.execute(gui.getDesktop())
