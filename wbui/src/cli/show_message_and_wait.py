import base64
import sys

def run(options, args):
    sys.stdout.write(base64.b64decode(args[0]))
    sys.stdin.readline()
