# -*- coding: utf-8 -*-
'''
@author: shimarin
'''

import os
import sys
import hashlib
from optparse import OptionParser, OptionValueError

import system
import cli
import subprocess

usage = "[options] sourcetarball targetdir"

def generateExtractorBySuffix(source, dbfile):
    for k,v in {".tar.gz":["/bin/tar","zxf",source,"-O",dbfile], ".tar.bz2":["/bin/tar","jxf",source,"-O",dbfile],".tar.lzma":["/bin/tar","Jxf",source,"-O",dbfile],".tar.xz":["/bin/tar","Jxf",source,"-O",dbfile]}.iteritems():
        if source.endswith(k): return v
    return None

def setupOptions(parser):
    pass

def read_filedb(filedb):
    files = {}
    line = filedb.readline()
    while line:
        if line.startswith("#"): continue
        row = line.strip().split('\t')
        if len(row) > 1:
            files[row[0]] = row[1]
        else:
            files[row[0]] = None
        line = filedb.readline()
    return files

def isModified(filename, md5):
    if os.path.islink(filename): return False
    m = hashlib.md5()
    with open(filename) as f: m.update(f.read())
    return md5 != m.hexdigest()

def run(options, args):
    if len(args) < 2: raise cli.Error("Insufficient parameters.")

    source = args[0]
    target = args[1]
    
    s = system.getSystem()
    
    extractor = generateExtractorBySuffix(source, "./var/db/wb/filedb")
    if extractor == None: raise cli.Error("Unknown archive filename suffix")

    #print "subprocess.popen(tar)"
    tar = subprocess.Popen(extractor, shell=False, stdout=subprocess.PIPE,close_fds=True)

    srcfiles = None
    try:
        #print "read_filedb"
        srcfiles = read_filedb(tar.stdout)
    except KeyboardInterrupt:
        tar.terminate()
        tar.stdout.close()
        tar.wait()
        exit(130)

    tar.stdout.close()
    #print "tar.wait()..."
    tar.wait()

    dstfiles = None
    with open("%s/var/db/wb/filedb" % (target)) as filedb:
        dstfiles = read_filedb(filedb)

    # generate exclude/delete list
    for k,v in dstfiles.iteritems():
        target_filename = "%s%s" % (target,k)
        if not os.path.exists(target_filename): continue
        if not(srcfiles.has_key(k)): 
            if v == None or not isModified(target_filename, v):
                print "D %s" % (k)
            continue
        if not(os.path.islink(target_filename)) and v == srcfiles[k]:
            print "X %s" % (k)
            continue
        # 特定のロケーション以下の場合
        if any(map(lambda x:k.startswith(x), ("/etc/","/var/","/root/",))): 
            # 変更されている場合は上書きしない
            if isModified(target_filename, v): print "X %s" % (k)

