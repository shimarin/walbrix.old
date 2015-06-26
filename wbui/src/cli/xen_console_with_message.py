# -*- coding: utf-8 -*-
'''
@author: shimarin
'''

import os
import sys
import codecs
import curses
from optparse import OptionParser, OptionValueError

import cli
import resource_loader
import gui

sys.stdout = codecs.getwriter('utf_8')(sys.stdout)

usage = "[options] domain_id_or_name"
# string resources

string_cli_conn_console = resource_loader.l({"en":u"It is connected to the console of the virtual machine %s.", "ja":u"仮想マシン %s のコンソールに接続されています。"})
string_cli_root_pass = resource_loader.l({"en":u"By default, the root password is Walbrix's serial number (non-registered=WBFREE01).", "ja":u"デフォルトのrootパスワードは Walbrixのシリアルナンバー(未登録時=WBFREE01)です。"})
string_cli_console_disconnect = resource_loader.l({"en":u"Press Ctrl+']' kay to disconnect from console.", "ja":u"コンソールから切断して戻るには Ctrlキーを押しながら']'を押してください。"})
string_cli_desc = resource_loader.l({"en":u"(If you do not see anything below, please try pressing the Enter key once)", "ja":u"(以下に何も表示されない場合は、Enterキーを一度押してみて下さい)"})

def setupOptions(parser):
    pass

def tput(capname, *args):
    sys.stdout.write(curses.tparm(curses.tigetstr(capname), *args))

def run(options, args):
    if len(args) < 1: raise cli.Error("Insufficient parameters.")

    domain = args[0]

    curses.setupterm()
    tput("sc")
    tput("cup", 24, 0)
    tput("setab", 6)
    tput("setaf", 4)
    print "[Walbrix]-------------------------------------------------------------"
    tput("sgr0")
    print string_cli_conn_console % unicode(domain)
    print string_cli_root_pass
    tput("setab", 7)
    tput("setaf", 1)
    print string_cli_console_disconnect
    tput("sgr0")
    tput("csr", 0, 23)
    tput("rc")

    print string_cli_desc

    os.execv("/usr/sbin/xl", ("/usr/sbin/xl", "console", domain))

