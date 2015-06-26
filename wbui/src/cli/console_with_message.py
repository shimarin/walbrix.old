# -*- coding: utf-8 -*-
'''
@author: shimarin
'''

from __future__ import print_function
import os
import sys
import curses
from optparse import OptionParser, OptionValueError

import system
import cli
import resource_loader
import gui

# string resources


gui.res.register("string_exit_to_console",resource_loader.l({"en":u"Enter 'exit' to return from console.", "ja":u"コンソールを終了して戻るには exit と入力して下さい。"}))



def tput(capname, *args):
    sys.stdout.write(curses.tparm(curses.tigetstr(capname), *args))

def run(options, args):
    #curses.setupterm()
    #tput("setab", 6)
    #tput("setaf", 4)
    print("[Walbrix]-------------------------------------------------------------")
    print(gui.res.string_exit_to_console.encode("utf-8"))
    print("----------------------------------------------------------------------")
    #tput("sgr0")

    if system.lang() == "ja":
        os.putenv("LANG", "ja_JP.utf8")
    
    os.execv("/bin/login", ("/bin/login", "-f", "root"))
