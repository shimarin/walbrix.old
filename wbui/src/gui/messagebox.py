# -*- coding:utf-8 -*-
'''
メッセージボックス(アラート)ダイアログを実装するモジュール

Created on 2011/05/01

@author: shimarin
'''

import gui
import gui.util
import gui.list

BUTTON_SPACE = 32

class MessageBox(gui.Window,gui.EventHandler):
    """
    メッセージボックス(アラート)ダイアログを表現するクラス
    """
    def __init__(self, text, buttons = ["ok"], bgcolor = None, default = 0, timeout = 0 ):
        """
        コンストラクタ
        text: ダイアログに表示するメッセージ
        buttons: 表示するボタンのID文字列("ok"や"cancel")のリスト
        bgcolor: ダイアログの背景色。Noneの場合 gui.res.color_dialog_positive
        default: デフォルトで選択されているボタンのインデックス
        timeout: defaultで指定されたボタンが押下されたものとして処理されるまでのタイムアウト
        """
        if bgcolor == None: bgcolor = gui.res.color_dialog_positive
        messagebox_buttons = {"ok":gui.res.button_ok, "cancel":gui.res.button_cancel}
        textImg = gui.util.render_font_with_wordwrap(gui.res.font_messagebox, 580, text)
        self.buttonsHeight = 0
        for button in buttons:
            self.buttonsHeight = max(self.buttonsHeight, messagebox_buttons[button].get_height())
        total_button_width = sum(messagebox_buttons[button].get_width() for button in buttons) + BUTTON_SPACE * (len(buttons) - 1)
        gui.Window.__init__(self, (max(textImg.get_width(), total_button_width) + 10, textImg.get_height() + self.buttonsHeight * 3 / 2 + 10))

        self.buttons = map(lambda b: [b, None], buttons)
        self.selected = default
        self.bgcolor = bgcolor
        self.content = gui.Bitmap(textImg)

        self.addChild("content", self.content, (5, 5))

        # ボタンの配置
        ox = self.getWidth() / 2 - total_button_width / 2
        for i in range(0,len(buttons)):
            buttonImg = messagebox_buttons[buttons[i]]
            x = ox
            y = textImg.get_height() + 5 + 24 - buttonImg.get_height() / 2
            button = gui.Button(buttonImg)
            if self.selected == i: button.setSelected(True)
            self.buttons[i][1] = button
            self.addChild(buttons[i], button, (x, y))
            ox += buttonImg.get_width() + BUTTON_SPACE

    def update_button_statuses(self):
        """
        直接呼び出すべきではない。
        """
        for i in range(0,len(self.buttons)):
            self.buttons[i][1].setSelected(self.selected == i)

    def execute(self, desktop):
        """
        このダイアログを実行する
        desktop: ダイアログを実行する gui.DesktopWindow
        return value: 選択されたボタンのID
        """
        with desktop.openDialog(self):
            return gui.eventLoop(self)
    
    def paint(self, surface):
        """
        ダイアログを描画する。直接呼び出すべきではない。
        """
        gui.util.draw_filled_round_rect_with_frame(surface, self.bgcolor, gui.res.color_dialog_frame, (0, 1, self.getWidth(), self.content.getHeight() + self.buttonsHeight / 2 + 8), 3, 5, 5)
        
    def select(self):
        """
        直接呼び出すべきではない。
        """
        self.setResult(self.buttons[self.selected][0])
        return True

    def cancel(self):
        """
        直接呼び出すべきではない。
        """
        self.setResult(None)
        return True

    def left(self):
        """
        直接呼び出すべきではない。
        """
        if self.selected > 0:
            self.selected -= 1
            self.update_button_statuses()
        return False

    def right(self):
        """
        直接呼び出すべきではない。
        """
        if self.selected < len(self.buttons) - 1:
            self.selected += 1
            self.update_button_statuses()
        return False

def execute(text, buttons = ["ok"], bgcolor = None, default = 0, timeout = 0):
    """
    メッセージボックス(アラート)ダイアログを実行する
    text: ダイアログに表示するメッセージ
    buttons: 表示するボタンのID文字列("ok"や"cancel")のリスト
    bgcolor: ダイアログの背景色。Noneの場合 gui.res.color_dialog_positive
    default: デフォルトで選択されているボタンのインデックス
    timeout: defaultで指定されたボタンが押下されたものとして処理されるまでのタイムアウト
    """
    messageBox = MessageBox(text, buttons, bgcolor, default, timeout)
    return messageBox.execute(gui.getDesktop())
