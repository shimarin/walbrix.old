# -*- coding:utf-8 -*-
import os
import zipfile
import urllib2
import shutil
import StringIO
import pygame
import threading
import time

import wbui
import footer
import status
import system
import util
import theme

import gui.selectbox
import gui.propertybox
import gui.messagebox
import dialogbox
import resource_loader

import gui_bench
import ntpclient
import resource_loader

# string resources

gui.res.register("string_english",resource_loader.l({"en":u"English", "ja":u"英語"}))
gui.res.register("string_japanese",resource_loader.l({"en":u"Japanese", "ja":u"日本語"}))
gui.res.register("string_central_server_conn_desc",resource_loader.l({"en":u"Specify whether to connect to a central server system. Some features will be disabled and is not connected to a central server.", "ja":u"システムが中央サーバへ接続するかどうかを設定します。中央サーバへ接続されていないと一部の機能が無効になります。"}))
gui.res.register("string_theme_setup",resource_loader.l({"en":u"Set the theme of WBUI. The theme directory should be the name of /usr/share/wbui/themes/theme.", "ja":u"WBUIのテーマを設定します。テーマのディレクトリは/usr/share/wbui/themes/テーマ名 となります。"}))
gui.res.register("string_utility_desc",resource_loader.l({"en":u"Utility is available to various functions over the network from a Web browser.", "ja":u"ユーティリティは、Webブラウザからネットワーク越しに利用できる各種機能です。"}))
gui.res.register("string_keyboard_specification",resource_loader.l({"en":u"You can specify the type of keyboard are connected.", "ja":u"接続されているキーボードの種類を指定することが出来ます。"}))
gui.res.register("string_graphic_display_desc",resource_loader.l({"en":u"To measure the speed of the graphics display.", "ja":u"グラフィック表示の速度を計測します。"}))
gui.res.register("string_login_console_desc",resource_loader.l({"en":u"Log in directly to the console of the operating system. Please use only If you have a high level knowledge of Linux", "ja":u"オペレーティングシステムのコンソールに直接ログインします。高いレベルの Linux知識をお持ちの方のみご使用下さい"}))
gui.res.register("string_conn_to_central_server",resource_loader.l({"en":u"You are connected to a central server", "ja":u"中央サーバに接続しています"}))
gui.res.register("string_not_conn_server",resource_loader.l({"en":u"Could not connect to a central server", "ja":u"中央サーバへ接続できませんでした"}))
gui.res.register("string_conn_enable",resource_loader.l({"en":u"Did you enable the connection to the central server", "ja":u"中央サーバへの接続を有効にしました"}))
gui.res.register("string_conn_disable",resource_loader.l({"en":u"Are you sure you want to disable the connection to a central server?", "ja":u"中央サーバへの接続を無効にしますか？"}))
gui.res.register("string_con_disconnect",resource_loader.l({"en":u"You have been disconnected from a central server", "ja":u"中央サーバから切断しています"}))
gui.res.register("string_con_not_disconnect",resource_loader.l({"en":u"Could not be disconnected from a central server", "ja":u"中央サーバから切断できませんでした"}))
gui.res.register("string_disabeled_connection",resource_loader.l({"en":u"You have disabled the connection to the central server", "ja":u"中央サーバへの接続を無効にしました"}))
gui.res.register("string_client_certificate",resource_loader.l({"en":u"To connect to a central server, a client certificate is required", "ja":u"中央サーバへ接続するには、クライアント証明書が必要です"}))
gui.res.register("string_enable_conn_server",resource_loader.l({"en":u"Do you want to enable connection to a central server?", "ja":u"中央サーバへ接続を有効にしますか？"}))
gui.res.register("string_download_id",resource_loader.l({"en":u"Download ID(bit.ly)", "ja":u"ダウンロードID(bit.ly)"}))
gui.res.register("string_theme_download",resource_loader.l({"en":u"Theme Download", "ja":u"テーマのダウンロード"}))

gui.res.register("string_options_error_desc",resource_loader.l({"en":u"The download does not exist, or the ID communication error(*bit.ly ID of case-insensitive).", "ja":u"そのダウンロードIDは存在しないか、通信エラーです(※bit.lyのIDは大文字小文字を区別します)。"}))
gui.res.register("string_zip_type",resource_loader.l({"en":u"File type is not a ZIP.", "ja":u"ファイルタイプがZIPではありません。"}))
gui.res.register("string_options_theme",resource_loader.l({"en":u"Theme %s is already present.", "ja":u"テーマ %s は既に存在しています。"}))
gui.res.register("string_theme_downloded_desc",resource_loader.l({"en":u"%s theme has been downloaded.", "ja":u"テーマ %s がダウンロードされました。"}))
gui.res.register("string_opt_download",resource_loader.l({"en":u"Download", "ja":u"ダウンロード"}))
gui.res.register("string_opt_choose_theme",resource_loader.l({"en":u"Choose a Theme", "ja":u"テーマの選択"}))
gui.res.register("string_apply_theme",resource_loader.l({"en":u"To apply this theme", "ja":u"このテーマを適用する"}))
gui.res.register("string_remove_theme",resource_loader.l({"en":u"To remove this theme", "ja":u"このテーマを削除する"}))
gui.res.register("string_option_theme_per",resource_loader.l({"en":u"Theme %s", "ja":u"テーマ %s"}))
gui.res.register("string_option_del_theme",resource_loader.l({"en":u"Are you sure to delete the %s theme?", "ja":u"テーマ %s を本当に削除しますか？"}))
gui.res.register("string_new_theme_desc",resource_loader.l({"en":u"Are you sure that you want to take effect immediately a new theme?", "ja":u"新しいテーマをすぐに反映させますか？"}))
gui.res.register("string_web_browser_desc",resource_loader.l({"en":u"The utility can be used only from a Web browser. Do you want to start?", "ja":u"ユーティリティは Webブラウザからのみ利用することが出来ます。起動しますか？"}))
gui.res.register("string_options_utility_desc",resource_loader.l({"en":u"To start the utility.available on the http://%s:%d. Please stop to protect the security, when you are finished using.", "ja":u"ユーティリティを起動しました。 http://%s:%d で利用できます。セキュリティ保護のため、使用を終えたら停止して下さい。"}))
gui.res.register("string_launched_desc",resource_loader.l({"en":u"Current utility http://%s: is being launched in the http://%s:%d . Are you sure you want to stop?", "ja":u"ユーティリティは現在 http://%s:%d で起動中です。停止しますか？"}))
gui.res.register("string_opt_stop_utility",resource_loader.l({"en":u"Stop the Utility.", "ja":u"ユーティリティを停止しました。"}))
gui.res.register("string_opt_keyboard",resource_loader.l({"en":u"Type of Keyboard", "ja":u"キーボードの種類"}))
gui.res.register("string_opt_keyboard_type_desc",resource_loader.l({"en":u"%s is set to the type of keyboard. Are you sure?", "ja":u"キーボードの種類を %s に設定します。よろしいですか？"}))
gui.res.register("string_setting_keyboard_typenew",resource_loader.l({"en":u"To set the type of keyboard.", "ja":u"キーボードの種類を設定しました。"}))
gui.res.register("string_linux_migration_desc",resource_loader.l({"en":u"Linux migration to the console. Do you want to allow this?", "ja":u"Linuxのコンソールに移行します。よろしいですか？"}))
gui.res.register("string_opt_conn_central_server",resource_loader.l({"en":u"Connect to Central Server", "ja":u"中央サーバとの接続"}))
gui.res.register("string_opt_to",resource_loader.l({"en":u"To", "ja":u"する"}))
gui.res.register("string_opt_not",resource_loader.l({"en":u"No", "ja":u"しない"}))
gui.res.register("string_opt_wbui_theme",resource_loader.l({"en":u"WBUI Theme", "ja":u"WBUIのテーマ"}))
gui.res.register("string_options_utility",resource_loader.l({"en":u"Utility", "ja":u"ユーティリティ"}))
gui.res.register("string_during_startup",resource_loader.l({"en":u"During startup", "ja":u"起動中"}))
gui.res.register("string_options_stopped",resource_loader.l({"en":u"Stopped", "ja":u"停止中"}))
gui.res.register("string_opt_other",resource_loader.l({"en":u"Other", "ja":u"その他"}))
gui.res.register("string_gui_benchmark",resource_loader.l({"en":u"GUI benchmark", "ja":u"GUIベンチマーク"}))
gui.res.register("string_linux_console_desc",resource_loader.l({"en":u"Switch to console", "ja":u"Linuxコンソールの利用"}))

string_adjust_time = resource_loader.l({"en":u"Adjust system clock", "ja":u"システム日時の調整"})
string_adjust_time_desc = resource_loader.l({"en":u"Automatically adjust system clock via NTP", "ja":u"インターネットを利用して自動的にシステム日時の設定を行います"})

keymap_names = {"us":gui.res.string_english, "jp106":gui.res.string_japanese}

canvas = None
cursor = None
active = None
selected = None
alpha = None
dalpha = None
blink_count = None
utility_running = None
openvpn_initlink = "/etc/runlevels/default/openvpn"

window = None

class Window(gui.list.List, gui.list.ListEventHandler):
    def __init__(self):
        gui.list.List.__init__(self, gui.res.contents_panel.get_size())
        self.setBgImage(gui.res.contents_panel)
        self.setEventHandler(self)
    def onChange(self, target):
        selected = self.getSelectedIndex()
        if selected == 0:
            footer.window.setText(gui.res.string_central_server_conn_desc)
        elif selected == 1:
            footer.window.setText(gui.res.string_theme_setup)
        elif selected == 2:
            footer.window.setText(gui.res.string_utility_desc)
        elif selected == 3:
            footer.window.setText(gui.res.string_keyboard_specification)
        elif selected == 4:
            footer.window.setText(string_adjust_time_desc)
        elif selected == 5:
            footer.window.setText(gui.res.string_graphic_display_desc)
        elif selected == 6:
            footer.window.setText(gui.res.string_login_console_desc)

class OptionListItem(gui.list.ListItem):
    def __init__(self, label, value, value_color):
        self.hdr_img = gui.res.font_options_list.render(label, True, (255, 255, 255))
        self.value_img = gui.res.font_options_list.render(value, True, value_color)
        gui.list.ListItem.__init__(self, max(self.hdr_img.get_height(), self.value_img.get_height()))
    def paint(self, surface, y):
        surface.blit(self.hdr_img, (0, y) )
        surface.blit(self.value_img, (surface.get_width() - self.value_img.get_width(), y))

def init():
    global window
    if window != None: return

    global utility_running
    utility_running = util.is_utility_running()

    gui.res.register("font_options_list", gui.res.font_system.getFont(20))


    # "console_l_ja.png" for japanese version
    # "console_l_en.png" for english version
    console_l_filename = resource_loader.l({
        "en":"console_l_en.png",
        "ja":"console_l_ja.png"})

    gui.res.register("console_l", resource_loader.loadImage(console_l_filename))

    window = Window()

def enable_openvpn():
    system.exec_shell("rc-update add openvpn default")
    system.exec_shell("/etc/init.d/openvpn start")

    with dialogbox.messagebox.open(gui.res.string_conn_to_central_server):
        status.refresh()
        i = 0
        while status.is_connected() == False:
            gui.yieldFrame()
            status.refresh()
            i += 1
            if i > 90: break

    if not status.is_connected():
        refresh()
        wbui.play_sound("fail")
        dialogbox.messagebox.execute(gui.res.string_not_conn_server, None, gui.res.caution_sign)
        return

    #/etc/openvpn/up.shでやることに
    #system.exec_shell("/etc/init.d/avahi-daemon restart")
    refresh()
    wbui.play_sound("success")
    dialogbox.messagebox.execute(gui.res.string_conn_enable)

def setup_openvpn():
    if openvpn_enabled:
        if dialogbox.messagebox.execute(gui.res.string_conn_disable, dialogbox.DialogBox.OKCANCEL()) != "ok": return False
        system.exec_shell("/etc/init.d/openvpn stop")
        os.unlink(openvpn_initlink)

        with dialogbox.messagebox.open(gui.res.string_con_disconnect):
            wbui.status.refresh()
            i = 0
            while status.is_connected():
                gui.yieldFrame()
                status.refresh()
                i += 1
                if i > 90: break

        if not status.is_connected():
            refresh()
            wbui.play_sound("fail")
            dialogbox.messagebox.execute(gui.res.string_con_not_disconnect, None, gui.res.caution_sign)
            return
        #else
        refresh()
        dialogbox.messagebox.execute(gui.res.string_disabeled_connection)
    else:
        if not os.path.isfile("/etc/openvpn/client.crt"):
            dialogbox.messagebox.execute(gui.res.string_client_certificate, None, gui.res.caution_sign)
            return
        #else
        if dialogbox.messagebox.execute(gui.res.string_enable_conn_server, dialogbox.DialogBox.OKCANCEL()) != "ok": return False
        #else
        enable_openvpn()
        return True

def download_theme():
    fields = [{"id":"shortenurl","label":gui.res.string_download_id,"value":"??????","acceptable_chars":"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"}]
    while True:
        values = gui.propertybox.execute(gui.res.string_theme_download,fields)
        if values == None: return None

        shortenurl = values["shortenurl"]
        fields[0]["value"] = shortenurl

        url = None
        try:
            url = urllib2.urlopen("http://bit.ly/" + shortenurl, None, 10)
        except: #urllib2.HTTPError
            gui.messagebox.execute(gui.res.string_options_error_desc,["ok"],(192,48,48,192))
            continue

        if url.info().getheader("content-type") != "application/zip":
            gui.messagebox.execute(gui.res.string_zip_type,["ok"],(192,48,48,192))
            continue

        real_url = url.geturl()
        theme_name = os.path.splitext(os.path.basename(real_url))[0]

        if os.path.isdir(theme.getThemeDir(theme_name)):
            gui.messagebox.execute(gui.res.string_options_theme % (theme_name),["ok"],(192,48,48,192))
            url.close()
            continue

        zf = zipfile.ZipFile(StringIO.StringIO(url.read()))
        url.close()
        theme_path = theme.getThemeDir(theme_name)
        os.mkdir(theme_path)
        zf.extractall(theme_path)
        zf.close()
        gui.messagebox.execute(gui.res.string_theme_downloded_desc % (theme_name))

        return theme_name

def setup_theme():
    # テーマ選択ボックスのセットアップ
    options = map(lambda x: {"id":x,"label":x}, theme.getAvailableThemeList())
    options.append({"id":0, "label":gui.res.string_opt_download})
    # テーマを選択させる
    selected_theme = gui.selectbox.execute(gui.res.string_opt_choose_theme, options)

    # ダウンロードが選択された場合
    if selected_theme == 0: selected_theme = download_theme()
    if selected_theme == None: return False

    options = [{"id":"set","label":gui.res.string_apply_theme},{"id":"delete","label":gui.res.string_remove_theme}]
    if selected_theme == "default" or selected_theme == theme.getTheme(): # defaultテーマや選択中のテーマは削除させない
        del options[1]["id"]

    action = gui.selectbox.execute(gui.res.string_option_theme_per % (selected_theme), options)

    if action == None: return False
    if action == "delete":
        if dialogbox.messagebox.execute(gui.res.string_option_del_theme % (selected_theme), dialogbox.DialogBox.OKCANCEL(), gui.res.caution_sign) != "ok": return False
        #else
        shutil.rmtree(theme.getThemeDir(selected_theme))
        dialogbox.messagebox.execute(gui.res.string_option_del_theme % (selected_theme))
        return True
    elif action == "set":
        try :
            theme.setTheme(selected_theme)
        except Exception as e:
            dialogbox.messagebox.execute(str(e), None, gui.res.caution_sign)
            return False
            
        if dialogbox.messagebox.execute(gui.res.string_new_theme_desc, dialogbox.DialogBox.OKCANCEL()) != "ok": return True
        #else
        pygame.quit()
        wbui.restart()

def setup_utility():
    ipaddress = status.get_ip_address()
    if ipaddress == None: ipaddress = "???.???.???.???"

    if not utility_running:
        if dialogbox.messagebox.execute(gui.res.string_web_browser_desc, dialogbox.DialogBox.OKCANCEL()) != "ok": return False
        port = util.start_utility()
        dialogbox.messagebox.execute(gui.res.string_options_utility_desc % (ipaddress, port))

    else:
        if dialogbox.messagebox.execute(gui.res.string_launched_desc % (ipaddress, util.get_utility_port()), dialogbox.DialogBox.OKCANCEL()) != "ok": return False

        util.stop_utility()
        dialogbox.messagebox.execute(gui.res.string_opt_stop_utility)

    return True

def setup_keymap():
    options = map(lambda x: {"id":x, "label":keymap_names[x]}, keymap_names)
    selected_keymap = gui.selectbox.execute(gui.res.string_opt_keyboard, options)
    if selected_keymap == None: return
    if dialogbox.messagebox.execute(gui.res.string_opt_keyboard_type_desc % (keymap_names[selected_keymap]), dialogbox.DialogBox.OKCANCEL()) != "ok": return False
    
    system.set_system_keymap(selected_keymap)
    global keymap
    keymap = system.get_system_keymap()
    dialogbox.messagebox.execute(gui.res.string_setting_keyboard_typenew)
    return True

def exec_console():
    if dialogbox.messagebox.execute(gui.res.string_linux_migration_desc, dialogbox.DialogBox.OKCANCEL(), gui.res.console_l) != "ok": return False
    pygame.quit()
    os.execv("/usr/bin/openvt", ["openvt", "-wsl", "--", "/usr/bin/jfbterm", "-q", "-e", "/usr/sbin/wb", "console-with-message"])

def refresh():
    global openvpn_enabled, utility_running, keymap
    openvpn_enabled = os.path.islink(openvpn_initlink)
    utility_running = util.is_utility_running()
    s = system.getSystem()
    keymap = s.getSystemKeymap()

    window.clearItem()
    window.addItem(OptionListItem(gui.res.string_opt_conn_central_server, gui.res.string_opt_to if openvpn_enabled else gui.res.string_opt_not, (96,255,96) if openvpn_enabled else (255,96,96)))
    window.addItem(OptionListItem(gui.res.string_opt_wbui_theme, theme.getTheme(), (96, 255, 96)))
    window.addItem(OptionListItem(gui.res.string_options_utility, gui.res.string_during_startup if utility_running else gui.res.string_options_stopped, (96,255,96)))
    window.addItem(OptionListItem(gui.res.string_opt_keyboard, gui.res.string_opt_other if not keymap in keymap_names else keymap_names[keymap], (96,255,96)))
    window.addItem(gui.list.TextListItem(string_adjust_time, gui.res.font_options_list))
    window.addItem(gui.list.TextListItem(gui.res.string_gui_benchmark, gui.res.font_options_list))
    if s.isRunningAsGetty(): window.addItem(gui.list.TextListItem(gui.res.string_linux_console_desc, gui.res.font_options_list))

def main():
    refresh()
    while True:
        window.onChange(window)
        rst = gui.eventLoop(window)
        if rst == None: break
        window.keepShowingCursor()
        funcs = ( setup_openvpn, setup_theme, setup_utility, setup_keymap, ntpclient.adjust_time, gui_bench.benchmark_gui, exec_console )
        if funcs[rst]():
            refresh()
