'''
Created on 2011/05/23

@author: shimarin
'''

import wbui

usage = ""

def setupOptions(parser):
    parser.add_option("-f", "--show-fps", dest="show_fps", action="store_true", help="Show FPS", default=False)

def run(options, args):
    wbui.main(True)
