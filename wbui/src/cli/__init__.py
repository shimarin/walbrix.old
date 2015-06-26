# -*- coding:utf-8 -*-

from __future__ import print_function
import imp
from optparse import OptionParser

version = "0.1"
subcommands = {}

class Error(Exception):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)

def register(name, description):
    subcommands[name] = description

def dynamic_import(name):
    if name in sys.modules: return None
    fp, pathname, description = imp.find_module(name, __path__)
    try:
        return imp.load_module(name, fp, pathname, description)
    finally:
        # Since we may exit via an exception, close fp explicitly.
        if fp: fp.close()

def run():
    if len(sys.argv) < 2:
        print("Subcommand must be specified.", file=sys.stderr)
        exit(1)

    subcommand = sys.argv[1]

    try:
        module = dynamic_import(subcommand.replace("-", "_"))
        if module is None:
            print >>sys.stderr, "Invalid subcommand '%s'." % subcommand
            exit(1)
        parser = OptionParser(usage="usage: %prog" + (" %s %s" % (subcommand, module.usage if hasattr(module, "usage") else "[options]")), version="%prog " + version)
        parser.disable_interspersed_args()
        if hasattr(module, "setupOptions"):
            module.setupOptions(parser)
        (options, args) = parser.parse_args(sys.argv[2:])
        module.run(options, args)
    except KeyboardInterrupt as e:
        exit(130)
    except ImportError as e:
        print(e, file=sys.stderr)
        print("Subcommand '%s' doesn't exist." % subcommand, file=sys.stderr)
        exit(1)
    except Error as e:
        print(e, file=sys.stderr)
        exit(1)

################ compatibility code below ####################

import os
import sys

def wbui_path():
    return os.path.abspath(os.path.dirname(os.path.realpath(sys.argv[0])))
