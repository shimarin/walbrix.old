import os
import fcntl
import time
import re
import string
import math
import time

KIOCSOUND = 0x4B2F
CLOCK_TICK_RATE = 1193180

tempo = 120
octave = 4
notelen = 4

mml_re = re.compile("^([cdefgab][+-]?|[rlo])[0-9]*[\.]?")
num_re = re.compile("^[0-9]+")

notes = {'c':-9, 'd':-7, 'e':-5, 'f':-4, 'g':-2, 'a':0, 'b':2}

r = math.pow(2.0, 1.0 /12.0)

def beep(hz, len):
    fd = os.open("/dev/console", os.O_WRONLY)
    try:
        fcntl.ioctl(fd, KIOCSOUND, CLOCK_TICK_RATE / int(hz))
        try:
            time.sleep(len)
        finally:
            fcntl.ioctl(fd, 0x4B2F, 0)
    finally:
        os.close(fd)

def exec_mml_part(mml_part):
    note_char = mml_part[0]
    mml_part = mml_part[1:]
    if note_char in notes:
        hn = 0
        if len(mml_part) > 0:
            if mml_part[0] == '+':
                hn = 1
                mml_part = mml_part[1:]
            elif mml_part[0] == '-': 
                hn = -1
                mml_part = mml_part[1:]
        noteno = 69 + notes[note_char] + hn

        freq = 440.0
        if noteno > 69:
            for i in range(69, noteno):
                freq *= r
        elif noteno < 69:
            for i in range(noteno, 69):
                freq /= r

        _len = notelen
        if len(mml_part) > 0:
            num = num_re.match(mml_part).group(0)
            mml_part = mml_part[len(num):]
            _len = int(num)
        if len(mml_part) > 0:
            if mml_part[0] == '.': _len = _len * 2 / 3

        beep(freq, float(240 / _len) / tempo)
    elif note_char == 'r':
        _len = notelen
        if len(mml_part) > 0:
            num = num_re.match(mml_part).group(0)
            mml_part = mml_part[len(num):]
            _len = int(num)
        time.sleep(float(240 / _len) / tempo)

def exec_mml(mml):
    mml_match = mml_re.match(mml)
    while mml_match != None:
        mml_part = mml_match.group(0)
        exec_mml_part(mml_part)
        mml = mml[len(mml_part):]
        mml_match = mml_re.match(mml)

def run(options, args):
    #beep(440, 0.5)
    for arg in args:
        exec_mml(string.lower(arg))
