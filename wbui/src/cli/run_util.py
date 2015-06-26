#!/usr/bin/python
# -*- coding:utf-8 -*-

import util

usage=""

def setupOptions(parser):
    parser.add_option("-p", "--port", dest="port", type="int", help="Port number to listen", default=0)

def run(options, args):
    port = options.port

    util.main(port)
