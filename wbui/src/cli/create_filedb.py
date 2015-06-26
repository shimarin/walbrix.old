import os
import sys
import hashlib

basedir = "."

def process_dir(dir):
    for item in os.listdir(basedir + '/' + dir):
        k = basedir + '/' + dir + '/' + item
        if os.path.isfile(k) and not os.path.islink(k):
            m = hashlib.md5()
            with open(k) as f:
                m.update(f.read())
                print("%s/%s\t%s" % (dir, item, m.hexdigest()))
        elif os.path.isdir(k) and not os.path.islink(k):
            process_dir("%s/%s" % (dir, item))
        else:
            print("%s/%s" % (dir, item))


def run(options, args):
    if len(args) >= 1: basedir = sys.argv[0]

    process_dir("")
