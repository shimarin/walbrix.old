import os
import sys

import cli.collect_sysfiles

srcdir = None
distfiles = "./distfiles"
processed_listfiles = {}
processed_distfiles = {}

def process_listfile(listfile):
    if processed_listfiles.has_key(listfile): return
    with open(listfile) as f:
        line = f.readline()
        while line:
            if line.startswith("#"):
                if line.startswith("#require "):
                    process_listfile(cli.collect_sysfiles.parse_require(listfile, line))
                else:
                    distfile = None
                    if line.startswith("#copy ") or line.startswith("#extract "):
                        distfile = os.path.normpath("%s/%s" % (distfiles, line.strip().split(" ")[1]))
                    elif line.startswith("#patchsinglefile "):
                        distfile = os.path.normpath("%s/%s" % (distfiles, line.strip().split(" ")[2]))
                    elif line.startswith("#portage "):
                        distfile = os.path.normpath("%s/var/db/pkg/%s/CONTENTS" % (srcdir if srcdir else cli.collect_sysfiles.vars["ARCH"], line.strip().split(" ")[1]))
                    distfile = cli.collect_sysfiles.apply_variables(distfile)
                    if distfile and not processed_distfiles.has_key(distfile):
                        processed_distfiles[distfile] = None
                        print distfile
            else:
                pass
            line = f.readline()
    processed_listfiles[listfile] = None
    print listfile

def setupOptions(parser):
    parser.add_option("-g", "--region", dest="region", help="Region name", default="jp")
    parser.add_option("-l", "--language", dest="language", help="Language name", default=None)
    parser.add_option("-a", "--arch", dest="arch", help="Architecture(x86_64/i686)", default=os.environ.get("ARCH") if "ARCH" in os.environ else os.uname()[4])
    parser.add_option("-s", "--srcdir", dest="srcdir", help="Source directory which contains /var/db/pkg",default=None)

def run(options, args):
    if len(args) < 1: raise Exception("Insufficient parameters")

    cli.collect_sysfiles.vars["ARCH"] = options.arch
    cli.collect_sysfiles.vars["REGION"] = options.region
    cli.collect_sysfiles.vars["LANGUAGE"] = options.language if options.language != None else ("ja" if options.region == "jp" else "en")
    srcdir = options.srcdir

    listfiles = args

    for listfile in listfiles:
        process_listfile(listfile)
