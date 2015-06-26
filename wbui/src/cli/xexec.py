# -*- coding: utf-8 -*-
'''
@author: shimarin
'''

import os
import time
import subprocess

def setupOptions(parser):
    parser.add_option("-t", "--use-tcp", dest="use_tcp", action="store_true", help="Use TCP instead of UNIX domain socket", default=False)

def run(options, args):
    x = subprocess.Popen(["/usr/bin/X"], shell=False, close_fds=True)
    retry = 3
    while not os.path.exists("/tmp/.X11-unix/X0") and retry > 0:
        time.sleep(1)
        retry -= 1

    os.putenv("DISPLAY", "localhost:0" if options.use_tcp else "unix:0")
    cmdline = args
    if len(cmdline) == 0: cmdline = ["/usr/bin/xterm", "-ls"]
    xterm = subprocess.Popen(cmdline, shell=False, close_fds=True)
    xterm.wait()
    x.terminate()
    x.wait()
