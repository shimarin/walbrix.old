# -*- coding:utf-8 -*-
'''
プログレスバーダイアログを実装するモジュール

Created on 2011/05/01

@author: shimarin
'''

import gui
import gui.util
import gui.list
import pygame
import threading

progressbar_buttons = {"cancel":"button_cancel"}

class ProgressBar(gui.Window,gui.EventHandler):
    """
    プログレスバーダイアログを表現するクラス
    """
    def __init__(self, text, bgcolor = None):
        """
        コンストラクタ
        text: プログレスバーダイアログに表示させるテキスト
        bgcolor: ダイアログの背景色。 None の場合は gui.res.color_dialog_positive が使用される
        """
        if bgcolor == None: bgcolor = gui.res.color_dialog_positive
        textImg = gui.util.render_font_with_wordwrap(gui.res.font_messagebox, 580, text, gui.res.color_text)
        self.barImg = pygame.Surface((textImg.get_width(), 8), pygame.SRCALPHA, 32)
        gui.Window.__init__(self, (textImg.get_width() + 10, textImg.get_height() + self.barImg.get_height() + 10))

        self.bgcolor = bgcolor
        self.content = gui.Bitmap(textImg)
        self.progress = 0.0
        self.stopRequested = False
        self.threadToWatch = None
        self.cancelRequested = False

        self.addChild("content", self.content, (5, 5))

    def setProgress(self, progress):
        """
        プログレスバーの進捗をセットする。
        progress: 進捗 ( 0.0 - 1.0 )
        """
        self.progress = progress

    def execute(self, desktop, threadToWatch):
        """
        使用非推奨
        """
        self.threadToWatch = threadToWatch
        self.stopArg = None
        desktop.setDialog(self)
        result = gui.eventLoop(self)
        desktop.setDialog(None)
        return result
    
    def paint(self, surface):
        """
        プログレスバーダイアログを描画する。直接呼び出すべきではない。
        """
        gui.util.draw_filled_round_rect_with_frame(surface, self.bgcolor, (255,255,255), (0, 1, self.getWidth(), self.content.getHeight() + self.barImg.get_height()+ 10), 3, 5, 5)
        self.barImg.fill((0,0,0,0))
        if self.progress > 0.0:
            alpha = gui.util.get_cycling_value_by_time((16,128), 2000)
            pygame.draw.rect(self.barImg, (255,255,0, alpha), pygame.Rect(0,0,int(self.content.getWidth() * self.progress), self.barImg.get_height()))
            surface.blit(self.barImg, (5, 5 + self.content.getHeight()))
    
    def cancel(self):
        """
        使用非推奨
        """
        if self.threadToWatch is None: return True
        self.cancelRequested = True
        return False
    
    def frame(self):
        """
        使用非推奨
        """
        if self.stopRequested or (self.threadToWatch is not None and not self.threadToWatch.isAlive()):
            self.setResult(self.stopArg) 
            return True

    def isCancelRequested(self):
        """
        使用非推奨
        """
        return self.cancelRequested
    
    def stop(self, stopArg):
        """
        使用非推奨
        """
        self.stopRequested = True
        self.stopArg = stopArg

class SyncedProgressBar:
    """
    プログレスバーダイアログを Pythonのwith構文で使用するためのクラス。with構文のスコープ中、ダイアログが表示され続ける。スコープ内では ProgressBarクラスの setProgress() メソッドで進捗を更新し、 yieldFrame() メソッドを呼び出し続けることで画面表示の更新を継続する。
    with gui.progressbar.SynchedProgressBar(u"処理中...") as pb:
      while (...) #　時間のかかる処理
        pb.setProgress(progress)  # 進捗を 0.0-1.0の間で指定
        rst = pb.yieldFrame()
        if rst: break # yieldFrameが Trueを返してきたらキャンセル処理
    """
    def __init__(self, text, bgcolor=None):
        """
        コンストラクタ
        text: プログレスバーダイアログに表示するメッセージ
        bgcolor: プログレスバーダイアログの背景色。 Noneの場合 gui.res.color_dialog_positiveが使用される。
        transition: 
        """
        if bgcolor == None: bgcolor = gui.res.color_dialog_positive
        self.text = text
        self.bgcolor = bgcolor
    def __enter__(self):
        """
        with構文で使用された際に呼び出されるメソッド。直接呼び出すべきではない。
        return value: ProgressBar オブジェクト
        """
        self.progressBar = ProgressBar(self.text, self.bgcolor)
        gui.getDesktop().setDialog(self.progressBar)
        return self.progressBar
    def __exit__(self,exc_type, exc_value, traceback):
        """
        with構文のスコープが終わる際に呼び出されるメソッド。直接呼び出すべきではない。
        return value: ProgressBar オブジェクト
        """
        gui.getDesktop().setDialog(None)
        if exc_type: return False
        return True

def execute(progressBar, threadToWatch):
    """
    使用非推奨
    """
    return progressBar.execute(gui.getDesktop(), threadToWatch)
