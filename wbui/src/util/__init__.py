#!/usr/bin/python
# -*- coding:utf-8 -*-

import sys
import os
import subprocess
import BaseHTTPServer

import handler

# ユーティリティ(HTTPベース)
utility = None
utility_port = None

def start_utility():
    global utility
    global utility_port
    utility = subprocess.Popen("/usr/sbin/wb run-util", shell=True, stdout=subprocess.PIPE, close_fds=True)
    utility_port = int(utility.stdout.readline())
    return utility_port

def stop_utility():
    global utility
    if utility == None: return False
    utility.terminate()
    utility.wait()
    utility = None
    return True

def is_utility_running():
    return utility != None

def get_utility_port():
    global utility
    global utility_port
    if utility == None: return None
    return utility_port

def main(port = 0):
    script_path = os.path.abspath(os.path.dirname(__file__))
    os.chdir(script_path)

    server_address = ('', port)
    httpd = BaseHTTPServer.HTTPServer(server_address, handler.RequestHandler)
    print httpd.server_address[1]
    sys.stdout.flush()
    httpd.serve_forever()
