# -*- coding:utf-8 -*-
"""
GUIフレームワークのメインモジュール

@author: shimarin
"""

import math

import pygame
import gui.util
import gui.res

gui.res.register("color_dialog_frame", pygame.Color(255,255,255))
gui.res.register("color_dialog_positive", pygame.Color(48,48,192,192))
gui.res.register("color_dialog_negative", pygame.Color(192,48,48,192))
gui.res.register("color_cursor", pygame.Color(255,255,0))
gui.res.register("color_text", pygame.Color(255, 255, 255))
gui.res.register("color_text_shadow", pygame.Color(0, 0, 0, 96))
gui.res.register("frame_rate", 30)

def setScreen(screen):
    """
    GUIを表示するための画面をセットする。
    screen: GUIを表示するための画面を表現するpygameのSurfaceオブジェクト。多くの場合、これは pygame.display.set_mode()関数の実行によって得られた物理画面への参照となるだろう。
    """
    gui.res.register("screen", screen)

def getScreen():
    return gui.res.screen

def setClock(clock):
    """
    GUIを動作させるために使用する時計をセットする。
    clock: pygame.time.Clock() で作成された Clockオブジェクト
    """
    gui.res.register("clock", clock)

def getClock():
    """
    GUIを動作させるために使用されている時計を得る
    return value: pygame.time.Clockオブジェクト
    """
    return gui.res.clock

def isHighTimeToDrawFrame():
    return gui.res.clock.get_time() >= 1000 / frameRate

def setFrameRate(frameRate):
    """
    GUIのフレームレートを設定する。
    frameRate: 秒間のフレーム数
    """
    gui.res.register("frame_rate", frameRate)

def getFrameRate():
    """
    GUIのフレームレートを取得する
    return value: 秒間のフレーム数
    """
    return gui.res.frame_rate

def setDesktop(desktop):
    """
    GUIのルートウィンドウ(デスクトップウィンドウ) をセットする
    desktop: DesktopWindowオブジェクト
    """
    gui.res.register("desktop", desktop)

def getDesktop():
    """
    GUIのルートウィンドウ(デスクトップウィンドウ) を取得する
    return value: DesktopWindowオブジェクト
    """
    return gui.res.desktop

class Entity:
    """
    画面に表示されるオブジェクトの総称
    """
    def __init__(self, size):
        """
        コンストラクタ
        size: (幅, 高さ)
        """
        self.size = size
    
    def getSize(self):
        """
        このエンティティのサイズを得る
        return value: (幅, 高さ)
        """
        return self.size

    def getWidth(self):
        """
        このエンティティの幅を得る
        return value: 幅
        """
        return self.size[0]

    def getHeight(self):
        """
        このエンティティの高さを得る
        return value: 高さ
        """
        return self.size[1]

    def setSize(self, size):
        """
        このエンティティのサイズを変更する
        size: (幅, 高さ)
        """
        self.size = size

    def draw(self,surface):
        """
        このエンティティの描画する必要がある時に呼び出されるメソッド。デフォルトの実装は空
        surface: 描画対象となる pygame.Surface
        """
        pass

    def onAddedAsChild(self, parent):
        """
        このエンティティが何らかの親要素の子として追加された際に呼び出されるメソッド。デフォルトの実装は空
        parent: 親要素
        """
        pass

class Bitmap(Entity):
    """
    常に固定のビットマップを表示するエンティティ
    """
    def __init__(self, source):
        """
        コンストラクタ
        source: このエンティティが常に表示するビットマップ(pygame.Surface)
        """
        self.surface = source
        Entity.__init__(self, (self.surface.get_width(), self.surface.get_height()))
    
    def draw(self,surface):
        """
        ビットマップを描画する
        surface: 描画対象となる pygame.Surface
        """
        surface.blit(self.surface, (0, 0))

class Unclipped:
    """
    自らのサイズと位置に描画領域をクリッピングされずに描画されるエンティティを示す抽象クラス
    """
    def drawUnclipped(self, surface, offset):
        """
        このエンティティを描画する必要がある際に呼び出される。
        surface: 描画対象の pygame.Surface
        offset: surface上の描画起点
        """
        pass

class Button(Unclipped, Bitmap):
    """
    「ボタン」を表現するエンティティ。固定のビットマップを描画する点では Bitmap と同様だが、選択状態に応じて表示形態が変わる。選択状態にある際の視覚効果をなるべく制限しないよう、Unclippedなエンティティとなっている。
    """
    def __init__(self, source):
        """
        コンストラクタ
        source: ボタンとして表示されるビットマップ(pygame.Surface)
        """
        Bitmap.__init__(self, source)
        self.selected = False

    def setSelected(self, selected):
        """
        ボタンの選択状態を設定する
        selected: True=ボタンは選択状態,  False=ボタンは選択されていない状態
        """
        self.selected = selected

    def drawUnclipped(self,surface, offset):
        """
        ボタンの描画を行う。ボタンが選択状態にある場合はそれなりの視覚効果を伴う。
        surface: 描画対象の pygame.Surface
        offset: surface上の描画起点
        """
        if self.selected:
            # 0.8倍〜1.1倍
            k = gui.util.get_cycling_value_by_time((0.8, 1.1), 1000)
            button = pygame.transform.rotozoom(self.surface, 0, k)
            dx = (self.surface.get_width() - button.get_width()) / 2
            dy = (self.surface.get_height() - button.get_height()) / 2
            surface.blit(button, (offset[0] + dx, offset[1] + dy))
        else:
            surface.blit(self.surface, offset)

class Text(Bitmap):
    """
    指定のテキストを表示するエンティティ。
    """
    def __init__(self, source, color=None, antialias=True):
        """
        コンストラクタ
        source: 描画に使用されるフォント (pygame.Font)
        color: 描画されるテキストの色 (pygame.Color又はRGBAのタプル) Noneの場合 gui.res.color_textが用いられる
        antialias: アンチエイリアス処理をするかどうか
        """
        if color == None: color = gui.res.color_text
        self.font = source
        self.antialias = antialias
        self.color = color
        self.text = None
        self.surface = None
        Entity.__init__(self, (0, self.font.get_height()))
    
    def setText(self, text, max_width = None):
        """
        このエンティティが表示するテキストをセットする
        text: 表示されるテキスト
        """
        self.text = unicode(text)
        self.surface = self.font.render(text, self.antialias, self.color)
        width = self.surface.get_width()
        if max_width != None: width = min(max_width, width)
        self.setSize((width, self.surface.get_height()))

    def getText(self):
        return self.text

    def draw(self, surface):
        """
        テキストを描画する
        surface: 描画対象の pygame.Surface
        """
        if self.surface is not None: Bitmap.draw(self, surface)

class EditText(Text):

    CARET_WIDTH = 2

    def __init__(self, font, color=None, antialias=True):
        Text.__init__(self, font, color, antialias)
        self.show_caret = False
        self.acceptable_chars = None
        self.caret_color = gui.res.color_text
        self.password_mode = False

    def showCaret(self, show_caret = True):
        self.show_caret = show_caret

    def setPasswordMode(self, password_mode):
        self.password_mode = password_mode

    def setAcceptableChars(self, acceptable_chars):
        self.acceptable_chars = acceptable_chars

    def setCaretColor(self, color):
        self.caret_color = color

    def setText(self, text, max_width = None):
        """
        このエンティティが表示するテキストをセットする
        text: 表示されるテキスト
        """
        self.text = str(text)
        self.surface = self.font.render(self.text if not self.password_mode else '*' * len(self.text), self.antialias, self.color)
        width = self.surface.get_width() + EditText.CARET_WIDTH + 2
        if max_width != None: width = min(max_width, width)
        self.setSize((width, self.surface.get_height()))

    def draw(self, surface):
        """
        テキストを描画する
        surface: 描画対象の pygame.Surface
        """
        if self.surface is not None: Bitmap.draw(self, surface)
        if self.show_caret and gui.util.get_cycling_bool_by_time(1000):
            #キャレットの描画
            size = self.getSize()
            pygame.draw.rect(surface, self.caret_color, (size[0] -EditText.CARET_WIDTH, 2, 2, size[1] - 4))

    def keydown(self, key, unicode):
        if unicode == None or unicode == '': return
        if key == pygame.K_BACKSPACE:
            if len(self.getText()) > 0: self.setText(self.getText()[0:-1])
            return
        #else
        if ord(unicode) < 0x20: return
        if (self.acceptable_chars == None or unicode in self.acceptable_chars) and len(self.getText()) < max:
            self.setText(self.getText() + unicode)

class Transition:
    """
    視覚効果に用いるトランジションを表現するための抽象クラス。
    blit()メソッドをオーバーライドすることで様々なトランジションを定義する。
    """
    def __init__(self, duration = 250, start = True):
        """
        コンストラクタ
        duration: トランジションの時間的長さ(ms)
        start: このオブジェクトの生成と同時にトランジションを開始するかどうか
        """
        self.duration = duration
        self.start_time = pygame.time.get_ticks() if start else None
    def start(self):
        """
        トランジションを開始する。すでにトランジションが始まっている場合は開始地点にリセットされる。
        """
        self.start_time = pygame.time.get_ticks()
    def isOver(self):
        """
        トランジションが既に完了しているかどうかを返す
        return value: トランジションが完了している場合 True
        """
        return pygame.time.get_ticks() - self.start_time > self.duration
    def getPosition(self):
        """
        トランジションのタイムラインにおける現在地点を返す
        return value: 0.0=スタート地点 1.0=終了地点
        """
        if self.start_time == None: return None
        distance = pygame.time.get_ticks() - self.start_time
        if distance >= self.duration: return 1.0
        #else
        return float(distance) / self.duration
    def blit(self, src, dest, position):
        """
        トランジション対象のエンティティを描画する。このメソッドをオーバーライドして、getPosition()メソッドで得られる現在位置を元にsrcを変形したり、positionを変更するなどしてトランジションを表現する。
        src: 対象エンティティの描画済み pygame.Surface
        dest: 描画対象となる pygame.Surface
        position: 本来の描画位置
        """
        dest.blit(src, position)

class Window(Entity):
    """
    ウィンドウを表現するクラス
    本GUIフレームワークにおけるウィンドウとは、子エンティティをネスト可能なエンティティのことである。
    """
    def __init__(self, size):
        """
        コンストラクタ
        size: (幅, 高さ)
        """
        Entity.__init__(self, size)
        self.children = {}

    def addChild(self, name, obj, position, zorder = 0, transition = None):
        """
        このウィンドウに子エンティティを追加する。追加されたエンティティの onAddedAsChildメソッドが呼び出される。
        name: 子の名前。後で子エンティティを参照する際に使用される。
        obj: このウィンドウの子エンティティとなる Entity オブジェクト
        position: このウィンドウ内における子エンティティの座標 (x, y)
        zorder: 子エンティティのZオーダー。数値の高い物から先に描画される(背面に表示される)
        transition: この子エンティティに適用されるトランジションの Transition オブジェクト。Noneの場合トランジションなし
        """
        self.children[name] = [obj, position, zorder, transition]
        obj.onAddedAsChild(self)
        
    def getChild(self, name):
        """
        このウィンドウの子エンティティを取得する
        name: addChild() されたときの名前
        return value: Entity オブジェクト
        """
        return self.children[name][0] if name in self.children else None

    def getChildPosition(self, name):
        """
        指定された子エンティティの座標を得る
        name: addChild() されたときの名前
        return value: (x, y)
        """
        return self.children[name][1]

    def setChildPosition(self, name, position):
        """
        子エンティティの座標を指定の場所へ移動する
        name: addChild() されたときの名前
        position: (x, y)
        """
        self.children[name][1] = position

    def setTransition(self, name, transition):
        """
        子エンティティにトランジションを適用する
        name: addChild() されたときの名前
        transition: Transition オブジェクト又は None。Noneを指定した場合トランジションはキャンセルされる
        """
        self.children[name][3] = transition
    
    def removeChild(self, name):
        """
        子エンティティをこのウィンドウから取り除く
        name: addChild() されたときの名前
        """
        return self.children.pop(name)

    def placeCenterMiddle(self, child):
        """
        このウィンドウの中心に指定サイズの矩形を表示する際に用いるべき左上隅の座標を得る
        child: Entity オブジェクト又は (幅, 高さ)
        return value: (x, y)
        """
        if isinstance(child, Entity): return ((self.getWidth() - child.getWidth()) / 2, (self.getHeight() - child.getHeight()) / 2 )
        elif isinstance(child, tuple): return ((self.getWidth() - child[0]) / 2, (self.getHeight() - child[1]) / 2 )
        else: raise Exception("unknown type")

    def drawChild(self, surface, child, position, transition):
        """
        直接呼び出したりオーバーライドしたりされるべきでない
        """
        subsurface = pygame.Surface(child.getSize(), pygame.SRCALPHA|pygame.HWSURFACE, 32)
        child.draw(subsurface)
        if transition == None:
            surface.set_clip((0, 0, child.getWidth() + position[0], child.getHeight() + position[1]))
            surface.blit(subsurface, position)
            surface.set_clip(None)
        else:
            transition.blit(subsurface, surface, position)

    def drawUnclippedChild(self, surface, child, position):
        """
        直接呼び出したりオーバーライドしたりされるべきでない
        """
        child.drawUnclipped(surface, position);

    def drawChildren(self, surface, position):
        """
        直接呼び出したりオーバーライドしたりされるべきでない
        """
        children = self.children.values()
        children.sort(lambda x,y: y[2] - x[2])
        for obj in children:
            if isinstance(obj[0], Unclipped): self.drawUnclippedChild(surface, obj[0], (obj[1][0]+position[0],obj[1][1]+position[1]))
            else: self.drawChild(surface, obj[0], obj[1], obj[3])
            # 終わったトランジションは削除
            if obj[3] != None and obj[3].isOver(): obj[3] = None

    def draw(self,surface):
        """
        直接呼び出したりオーバーライドしたりされるべきでない
        """
        self.paint(surface)
        self.drawChildren(surface, (0, 0))

    def paint(self, surface):
        """
        このウィンドウのコンテンツを描画する必要がある際に呼び出される。このメソッドはあらゆる子エンティティの描画よりも先に呼び出されるため、ここで描画されるコンテンツはZオーダー的に常に一番奥に表示される。
        surface: 描画対象の pygame.Surface
        """
        pass

class Darkness(Window):
    """
    ダイアログボックス表示の際などに後方のエンティティを暗く表示するためデスクトップ全体を黒透過で覆うためのウィンドウ。
    TODO: Windowでなく Entityで十分ではないか？検討する
    """
    def __init__(self, size):
        """
        コンストラクタ
        size: このウィンドウのサイズ
        """
        Window.__init__(self, size)
        self.start_time = pygame.time.get_ticks()
    def paint(self, surface):
        """
        ウィンドウ全体を黒透過で塗りつぶす。透過の度合いは、このウィンドウが生成されてからの経過時間に伴って変化する(時間と共に暗くなる)。これによってフェードアウト的な効果を表現している。
        surface: 描画対象の pygame.Surface
        """
        surface.fill((0,0,0,gui.util.get_moving_value_by_time((38, 128), self.start_time, 200)))

class PopupTransition(Transition):
    """
    ダイアログボックスのポップアップを表現するためのトランジション
    """
    def __init__(self, duration = 200):
        """
        コンストラクタ
        duration: トランジションの時間的長さ
        """
        Transition.__init__(self, duration)
    def blit(self, src, dest, position):
        """
        対象をトランジションの時間的位置に従った横拡大率でサーフェスにblitする
        src: 描画済みのエンティティの pygame.Surface
        dest: 描画対象の pygame.Surface
        position: 本来(トランジション非適用時)の表示位置
        """
        # 0.2 - 1.0
        trans = 0.8 * self.getPosition() + 0.2
        mb = pygame.transform.scale(src, (int(src.get_width() * trans), src.get_height()))
        mb.fill((0,0,0,255 - int(255.0 * trans)), None, pygame.BLEND_RGBA_SUB)
        position = (position[0] + (src.get_width() - mb.get_width()) / 2, position[1])
        dest.blit(mb, position)

class DesktopWindow(Window):
    """
    GUIフレームワークのルートウィンドウ(デスクトップウィンドウ)を表現するクラス
    """

    class Dialog:
        def __init__(self, desktop, dialog):
            self.desktop = desktop
            self.dialog = dialog
        def __enter__(self):
            self.desktop.setDialog(self.dialog)
            return self.dialog
        def __exit__(self, exc_type, exc_value, traceback):
            self.desktop.setDialog(None)
            if exc_type: return False
            return True

    def __init__(self, size, backgroundResource=None):
        """
        コンストラクタ
        size: (幅, 高さ)  通常は物理画面の大きさ
        backgroundResource: 背景画像となる pygame.Surface 。 Noneの場合は gui.res.background が用いられる
        """
        Window.__init__(self, size)
        if backgroundResource == None: backgroundResource = gui.res.background
        self.background = backgroundResource
        self.dialog = None

    def setDialog(self, dialog):
        """
        ダイアログボックスを表示または終了する。ダイアログボックスの表示中、Zオーダーが 1以上の子エンティティは暗く表示される。Zオーダー 0 のエンティティについては不定となるため、ダイアログボックスを使用するアプリケーションではデスクトップウィンドウの子エンティティに Zオーダー 0を用いるべきでない。
        dialog: ダイアログボックスを表現する Entity オブジェクト。Noneを指定した場合ダイアログボックスの表示を終了する。
        """
        if dialog != None:
            if self.dialog != None: raise Exception("Nested dialog not supported")
            self.dialog = dialog
            self.addChild("darkness", Darkness(self.getSize()), (0, 0), 0)
            self.addChild("dialog", self.dialog, self.placeCenterMiddle(self.dialog), -1, PopupTransition())
        else:
            self.dialog = None
            self.removeChild("darkness")
            self.removeChild("dialog")

    def openDialog(self, dialog):
        return DesktopWindow.Dialog(self, dialog)

    def paint(self, surface):
        """
        バックグラウンド画像を描画する。カスタムのバックグラウンド描画を行うためにこのメソッドをオーバーライドできるが、対象サーフェスを余すことなく塗りつぶす必要があることに注意すること。
        surface: 描画対象となる pygame.Surface
        """
        surface.blit(self.background, (0, 0))

class EventHandler:
    """
    イベントハンドラの抽象クラス。Pythonでは多重継承が許されているため、しばしば Window クラスと多重継承して用いられる。
    """
    stack = []  # append/pop

    def __init__(self):
        """
        コンストラクタ
        """
        self.result = None
    def setResult(self, obj):
        """
        イベント処理メソッドが Trueを返す(イベントループからの脱出を促す)際に、このメソッドで何らかの処理結果を表すオブジェクトをセットしておくことができる。イベントループの実行者は、 getResult() メソッドを使ってそのオブジェクトにアクセスできる。
        obj: イベント処理の結果を示す何らかのオブジェクト
        """
        self.result = obj
    def getResult(self):
        """
        イベント処理が Trueを返してイベントループからの脱出を促された際にイベントハンドラによってセットされた価値のあるかもしれない情報を取得する。
        return value: 何らかのオブジェクト
        """
        return self.result
    def enterEventLoop(self):
        """
        イベントループに入った際に呼び出されるメソッド
        """
        return False
    def leaveEventLoop(self):
        """
        イベントループを抜ける際に呼び出されるメソッド
        """
        return False

    def whoisActuallyResponsible(self):
        return self

    def isActive(self):
        """
        このイベントハンドラが現在アクティブかどうかを返す
        return value: アクティブなら True
        """
        if len(EventHandler.stack) > 0:
            recent = EventHandler.stack[-1]
            if recent == None: return False
            if recent == self or recent.whoisActuallyResponsible() == self: return True
        return False

    def getActiveLevel(self):
        """
        このイベントハンドラのアクティブレベルを得る
        return value: 0=アクティブでない 1=アクティブだったが現在ネストされた別のイベントループが実行されている 2=アクティブである
        """
        if len(EventHandler.stack) > 0:
            recent = EventHandler.stack[-1]
            if recent == None: return 0
            if recent == self or recent.whoisActuallyResponsible() == self: return 2

        #else
        return 1 if self in EventHandler.stack else 0
    def up(self):
        """
        上方向キー押下イベント発生時に呼び出されるメソッド
        return value: イベントループを抜けるべきである場合 True
        """
        return False
    def right(self):
        """
        右方向キー押下イベント発生時に呼び出されるメソッド
        return value: イベントループを抜けるべきである場合 True
        """
        return False
    def down(self):
        """
        下方向キー押下イベント発生時に呼び出されるメソッド
        return value: イベントループを抜けるべきである場合 True
        """
        return False
    def left(self):
        """
        左方向キー押下イベント発生時に呼び出されるメソッド
        return value: イベントループを抜けるべきである場合 True
        """
        return False
    def select(self):
        """
        決定キー押下イベント発生時に呼び出されるメソッド
        return value: イベントループを抜けるべきである場合 True
        """
        return False
    def cancel(self):
        """
        キャンセルキー押下イベント発生時に呼び出されるメソッド
        return value: イベントループを抜けるべきである場合 True
        """
        self.result = None
        return True

    def keydown(self, key, unicode):
        return False

    def frame(self):
        """
        フレーム描画時に呼び出されるメソッド
        return value: イベントループを抜けるべきである場合 True
        """
        return False

    def yieldFrame(self):
        """
        このイベントハンドラを使って1フレームだけイベント処理を実行する
        return value: イベントループを抜けるべきである場合 True
        """
        return gui.yieldFrame(self)

def isSelectEvent(event):
    """
    イベントが決定キー押下イベントであるかどうかを返す
    event: pygame.event.Event オブジェクト
    return value: イベントが決定キー押下イベントであれば True
    """
    if event.type == pygame.JOYBUTTONDOWN and event.button == 0:
        return True
    elif event.type == pygame.KEYDOWN and (event.key == pygame.K_RETURN or event.key == pygame.K_KP_ENTER):
        return True
    return False

def isCancelEvent(event):
    """
    イベントがキャンセルキー押下イベントであるかどうかを返す
    event: pygame.event.Event オブジェクト
    return value: イベントがキャンセルキー押下イベントであれば True
    """
    if event.type == pygame.JOYBUTTONDOWN and event.button == 1:
        return True
    elif event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE:
        return True
    return False

def isLeftEvent(event):
    """
    イベントが左方向キー押下イベントであるかどうかを返す
    event: pygame.event.Event オブジェクト
    return value: イベントが左方向キー押下イベントであれば True
    """
    if event.type == pygame.JOYAXISMOTION and event.axis == 0 and event.value < -0.5:
        return True
    elif event.type == pygame.KEYDOWN and event.key == pygame.K_LEFT:
        return True
    return False

def isRightEvent(event):
    """
    イベントが右方向キー押下イベントであるかどうかを返す
    event: pygame.event.Event オブジェクト
    return value: イベントが右方向キー押下イベントであれば True
    """
    if event.type == pygame.JOYAXISMOTION and event.axis == 0 and event.value > 0.5:
        return True
    elif event.type == pygame.KEYDOWN and event.key == pygame.K_RIGHT:
        return True
    return False

def isUpEvent(event):
    """
    イベントが上方向キー押下イベントであるかどうかを返す
    event: pygame.event.Event オブジェクト
    return value: イベントが上方向キー押下イベントであれば True
    """
    if event.type == pygame.JOYAXISMOTION and event.axis == 1 and event.value < -0.5:
        return True
    elif event.type == pygame.KEYDOWN and event.key == pygame.K_UP:
        return True
    return False

def isDownEvent(event):
    """
    イベントが下方向キー押下イベントであるかどうかを返す
    event: pygame.event.Event オブジェクト
    return value: イベントが下方向キー押下イベントであれば True
    """
    if event.type == pygame.JOYAXISMOTION and event.axis == 1 and event.value > 0.5:
        return True
    elif event.type == pygame.KEYDOWN and event.key == pygame.K_DOWN:
        return True
    return False

def yieldFrame(eventHandler=None):
    """
    イベントキューに溜まっているイベントを eventHandlerにディスパッチし、GUIを1フレーム描画する。前回のフレームが表示された時刻から 1/フレームレート 秒が経過していない場合は経過するまで待ってから処理が行われる。
    本来はイベントループから呼び出される関数であるが、イベントループ外でも時間のかかる処理を行なっている際などに適宜この関数を呼び出すことでユーザーへの視覚効果を止めずに継続することができる。
    eventHandler: イベント処理を担当する EventHandlerオブジェクト。Noneの場合、キャンセルキー以外のイベントは捨てられる。
    return value: この関数を呼び出しているイベントループを抜けるべきである場合は True
    """
    EventHandler.stack.append(eventHandler)
    gui.res.clock.tick(gui.res.frame_rate)
    rst = False # there is any reason to break event loop
    for event in pygame.event.get():
        if eventHandler is not None:
            if isSelectEvent(event): rst = eventHandler.select()
            elif isCancelEvent(event): rst = eventHandler.cancel()
            elif isUpEvent(event): rst = eventHandler.up()
            elif isDownEvent(event): rst = eventHandler.down()
            elif isLeftEvent(event): rst = eventHandler.left()
            elif isRightEvent(event): rst = eventHandler.right()
            elif event.type == pygame.KEYDOWN: rst = eventHandler.keydown(event.key, event.unicode)
        else:
            if isCancelEvent(event): rst = True
        if rst: break

    gui.res.desktop.draw(gui.res.screen)
    pygame.display.flip()

    if rst: return True

    rst = eventHandler != None and eventHandler.frame()

    EventHandler.stack.pop()
    return rst

def eventLoop(eventHandler=None, frameFunc=None):
    """
    イベントループを実行する。イベントループの間、GUIの画面はフレームレート指定どおりの頻度で更新される(システムの処理能力が追いつかない場合はその限りではない)。イベントループは、イベントハンドラが何らかのイベント処理で Trueを返すまで継続する。
    eventHandler: イベント処理を担当する EventHandlerオブジェクト。Noneの場合、キャンセルキー以外のイベントは捨てられる。
    frameFunc: (イベントハンドラの frameイベントとは別に)各フレームの描画ごとに呼び出される関数。特別そのような処理をする必要がない場合はNoneで良い。
    return value: イベントハンドラが Trueを返した際にセットした result値
    """
    if eventHandler is not None:
        eventHandler.enterEventLoop()
    while True:
        if yieldFrame(eventHandler): break
        if frameFunc is not None: frameFunc()
        
    if eventHandler is not None:
        eventHandler.leaveEventLoop() 
        return eventHandler.getResult()
    #else
    return None

class FontFactory:
    def __init__(self, fontfile):
        self.fontfile = fontfile
        self.fonts = {}
    def getFont(self, size):
        if size in self.fonts: return self.fonts[size]
        font = pygame.font.Font(self.fontfile, size)
        self.fonts[size] = font
        return font
