# -*- coding:utf-8 -*-
import gui
import dialogbox.inputbox

class PropertyBox(gui.Window):
    def __init__(self, text, fields, bgcolor = None):
        self.bgcolor = bgcolor if bgcolor != None else gui.res.color_dialog_positive
        self.fields = fields
        # タイトル文字列
        self.textImg = gui.util.render_font_with_wordwrap(gui.res.font_messagebox, 580, text, gui.res.color_text)
        self.fields = fields
        self.list = self.create_list()

        # メッセージテキストのBitmapエンティティ作成
        text = gui.Bitmap(self.textImg) # 複数行テキストのBitmap Entityをフレームワーク側に用意することも検討

        gui.Window.__init__(self, self.getAppropriateSize())

        # このウィンドウの配下に配置する
        self.addChild("text", text, (5, 5))
        self.addChild("list", self.list, (5, 5 + self.textImg.get_height()))

    def getAppropriateSize(self):
        return  (self.list.getWidth() + 10, self.textImg.get_height() + self.list.getHeight() + 10)

    def create_list(self):
        optionfont = gui.res.font_select_option
        # フィールドリストから LavelValueItemのリストを作成
        items = map(lambda x: gui.list.LabelValueItem(x["label"],"***" if "password" in x and x["password"] else x["value"],optionfont,gui.res.color_text,(96,255,96), None, x), self.fields)
        # 最後のアイテムを「決定」テキストアイテムとする
        items.append(gui.list.CenteredTextListItem(u"決定", optionfont))
        # 全てのアイテムの合計高さ
        height = sum(map(lambda x: x.getHeight(), items))
        height = min(360, height) # 最大でも360pxとする
        # 最も横幅の広いアイテム
        width = max(self.textImg.get_width(), max(map(lambda x: x.getContentWidth(), items)))
        width = min(width, 580) # 最大でも 580pxとする
        # リストボックス作成
        return gui.list.List((width, height), items)

    def paint(self, surface):
        gui.util.draw_filled_round_rect_with_frame(surface, self.bgcolor, gui.res.color_dialog_frame, (0, 1, self.getWidth(), self.getHeight()), 3, 5, 5)

    def _collect_values(self):
        values = {}
        for field in self.fields:
            id = field["id"]
            value = field["value"]
            if "type" in field and field["type"] == "int": value = int(value)
            values[id] = value
        return values

    def execute(self, desktop):
        """
        このダイアログを実行する
        desktop: ダイアログを実行する gui.DesktopWindow
        return value: 編集されたフィールドリスト
        """
        while True:
            with desktop.openDialog(self): rst = gui.eventLoop(self.list)
            if rst == None: return None
            # else
            if self.list.getSelectedIndex() == self.list.getNumItems() - 1: break
            # else edit value
            field = self.list.getSelected().getData()
            selected_index = self.list.getSelectedIndex()
            min = 1
            max = 16
            is_password = "password" in field and field["password"] == True
            acceptable_chars = "0123456789abcdefghijklmnopqrstuvwxyz-_."
            if "type" in field and field["type"] == "int":
                max = 5
                acceptable_chars = "0123456789"
            elif is_password:
                acceptable_chars = None
            elif "acceptable_chars" in field:
                acceptable_chars = field["acceptable_chars"]
            inputbox = dialogbox.inputbox.PasswordInputBox(field["label"], field["value"]) if is_password else dialogbox.inputbox.TextInputBox(field["label"], field["value"], acceptable_chars=acceptable_chars) 
            rst = inputbox.execute(desktop)
            if rst != None: 
                field["value"] = rst
                self.list = self.create_list()
                self.list.setSelectedIndex(selected_index)
                self.setSize(self.getAppropriateSize())
                self.addChild("list", self.list, (5, 5 + self.textImg.get_height()))

        return self._collect_values()

def execute(text, fields, bgcolor = None):
    propertyBox = PropertyBox(text, fields, bgcolor)
    return propertyBox.execute(gui.getDesktop())
