# -*- coding:utf-8 -*-
from __future__ import print_function
'''
Created on 2011/05/23

@author: shimarin
'''

import os
import datetime
import sys
import traceback
import tempfile
import subprocess
import base64
import io

import pygame

import cli
from cli import launch_app
import system
import wbui
import resource_loader

usage = ""

LOG_FILE = "/var/log/wb.log"
COMMITID_FILE = "/usr/share/wbui/commit-id"
# string resources

string_cli_unknown = resource_loader.l({"en":u"Unknown", "ja":u"不明"})

string_cli_error = resource_loader.l({"en":u"An error has occurred in the WBUI. We regret any inconvenience. If possible, please disclose to us at Twitter @wbsupport photos of this screen.", "ja":u"WBUIでエラーが発生しました。ご迷惑をおかけして申し訳ありません。もしよろしければ、この画面の写真を Twitterにて @wbsupport へご開示下さい。"})
string_cli_wbui_restart = resource_loader.l({"en":u"[To restart the WBUI, press the Enter key]", "ja":u"[Enterキーで WBUIを再起動します]"})

def setupOptions(parser):
    pass

def run(options, args):
    exc = None
    try:
        wbui.main(False) # don't skip splash
        sys.exit(0)
    except Exception as e:
        exc = traceback.format_exc()
    if exc == None: return

    #print(exc, file=sys.stderr)
    with open(LOG_FILE, "a") as f:
        print(datetime.datetime.now().isoformat(), file=f)
        print(exc, file=f)

    uname = string_cli_unknown
    commit_id = string_cli_unknown
    try:
        uname = " ".join(os.uname())
        if os.path.isfile(COMMITID_FILE):
            with open(COMMITID_FILE) as f:
                commit_id = f.read().strip()
    except:
        pass

    msg = io.BytesIO()
    print(exc.strip(), file=msg)
    print((u"uname=%s, wbui version=%s, commit id=%s\n" % (uname, system.version, commit_id)).encode("utf-8"), file=msg)
    print(string_cli_error.encode("utf-8"), file=msg)
    msg.write(string_cli_wbui_restart.encode("utf-8"))

    encoded_msg = base64.b64encode(msg.getvalue())

    pygame.quit()

    if os.path.exists("/usr/bin/fbterm"):
    	os.execv("/usr/bin/openvt", ("openvt", "-ws", "--", "/usr/bin/fbterm", "--", "wb", "show_message_and_wait", encoded_msg)) 
    else:
        os.execv("/usr/sbin/wb", ("wb", "show_message_and_wait", encoded_msg))

