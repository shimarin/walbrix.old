# -*- coding:utf-8 -*-
import subprocess
import signal

import pygame

import gui
import dialogbox
import resource_loader

string_adjust_time_desc = resource_loader.l({"en":u"Proceed to adjust system clock via NTP?", "ja":u"インターネットを利用して自動的にシステム日時の設定を行います。よろしいですか?？"})
string_adjusting_time = resource_loader.l({"en":u"Adjusting system clock...", "ja":u"システム時刻を合わせています..."})
string_succeeded = resource_loader.l({"en":u"Adjusting succeeded.", "ja":u"システム日時の自動設定に成功しました"})
string_failed = resource_loader.l({"en":u"Adjusting failed.", "ja":u"システム日時の自動設定に失敗しました"})
string_cancelled = resource_loader.l({"en":u"Cancelled.", "ja":u"キャンセルされました"})

def reset_gui_clock():
    gui.setClock(pygame.time.Clock())

# None = cancelled
# True = succeeded
# False = failed
def exec_ntp_client(message):
    with dialogbox.messagebox.open(string_adjusting_time):
        init_ntpclient = subprocess.Popen("/etc/init.d/ntp-client restart", shell=True, close_fds=True)
        last_tick = pygame.time.get_ticks()
        while init_ntpclient.poll() == None:
            if last_tick > pygame.time.get_ticks(): reset_gui_clock()
            if gui.yieldFrame():
                init_ntpclient.send_signal(signal.SIGINT)
                return None
        reset_gui_clock()
        return (init_ntpclient.wait() == 0)

def adjust_time():
    if dialogbox.messagebox.execute(string_adjust_time_desc, dialogbox.DialogBox.OKCANCEL()) != "ok": return False

    result = exec_ntp_client(string_adjusting_time)

    if result == True:
        #wbui.play_sound("success")
        dialogbox.messagebox.execute(string_succeeded)
    elif result == False:
        #wbui.play_sound("fail")
        dialogbox.messagebox.execute(string_failed, None, gui.res.caution_sign)
    elif result == None:
        #wbui.play_sound("fail")
        dialogbox.messagebox.execute(string_cancelled, None, gui.res.caution_sign)

    return (result == True)
