# -*- coding: utf-8 -*-
import os,subprocess,glob
import system

def setupOptions(parser):
    pass

def run(options, args):
    disks = system.getSystem().listAvailableDisks()
    pvs = subprocess.Popen(["/sbin/pvs","--noheadings","--separator","\t"], shell=False, stdout=subprocess.PIPE, close_fds=True)
    line = pvs.stdout.readline()
    pv_names = []
    while line:
        pv_row = line.split("\t")
        pv_name = pv_row[0].strip()
        pv_vg = pv_row[1].strip()
        if pv_vg != "": # VGに所属してないPVは含めない                          
            pv_names.append(pv_name)
        line = pvs.stdout.readline()
    pvs.wait()

    s = system.getSystem()
    for disk in disks:
        kernelname = disk["logicalname"]
        logicalname = "/dev/" + kernelname
        # PV含みのやつは除外
        if any(s.partitionBelongsTo(x, logicalname) for x in pv_names): continue
        try:
            size = s.determineBlockdeviceSize(logicalname)
        except:
            continue # 開けない奴は除外（リムーバブルなどの可能性がある）
        print "%s\t%s\t%s\t%s" % (kernelname,disk['size'],disk['product'].strip(),disk['sectorSize'])

