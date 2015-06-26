# -*- coding: utf-8 -*-
'''
Created on 2011/05/18

@author: shimarin
'''

import os
import urllib2
import urlparse
import json
from optparse import OptionParser, OptionValueError

import system
import vm
import cli
import relative_path

def determineVmNameFromVaId(vaid):
    s = system.getSystem()
    lvs = s.listLogicalVolumes()
    def isexist(name):
        for lv in lvs:
            if lv["name"] == name: return True
        return False

    for i in range(0,10):
        vmname = vaid
        if i > 0: vmname += str(i)
        if not isexist(vmname): return vmname
    
    raise cli.Error("Failed to determine vm name automatically. Please specify manually.")

def determineMostCapableVolumeGroup():
    s = system.getSystem()
    vgs = s.listVolumeGroups("@wbvg")
    if len(vgs) == 0: raise cli.Error("There is no VolumeGroups looks useable. Please specify manually.")
    vgname = None
    max = 0.0
    for vg in vgs:
        free = vg["free"]
        if free > max:
            max = free
            vgname = vg["name"]
    if vgname is None: raise cli.Error("Something strange happened. couldn't determine the most capable VG.")
    return vgname

def determineTarDecompressOptionBySuffix(vasource):
    try:
        return {".gz":"-z", ".bz2":"-j",".lzma":"--lzma",".xz":"--xz"}[os.path.splitext(vasource)[1]]
    except KeyError:
        return ""

def concat(files, outfile):
    for file in files:
        if os.path.isfile(file):
            with open(file, "r") as f:
                outfile.write(f.read())

usage = "[options] vasource.tar[.(gz|bz2|lzma|xz)]"

def setupOptions(parser):
    s = system.getSystem()
    arch = s.getArchitectureString()
    defaultRam = 96 if arch == "i686" else 128

    parser.add_option("-v", "--vg", dest="vg", help="Volume group name to install VA default=automatically chosen", default=None)
    parser.add_option("-n", "--name", dest="name", help="VM name to create default=determined from filename", default=None)
    parser.add_option("-L", "--size", dest="size", type="int", help="size of logical volume for the application(in gigabytes)", default=None)
    parser.add_option("-r", "--ram", dest="ram", type="int", help="RAM size for new VM in megabytes", default=None)
    parser.add_option("-c", "--extract-only", dest="extract_only", action="store_true", help="Don't make any changes to extracted files", default=False)
    parser.add_option("-k", "--copy-pubkey", dest="copy_pubkey", action="store_true", help="Copy ssh public keys(id_rsa/dsa.pub, authorized_keys) to extracted VM's /root/.ssh/authorized_keys")
    parser.add_option("-l", "--leave-on-fail", dest="leave_on_fail", action="store_true", help="Don't remove Logical Volume even if installation fails.", default=False)

def load_json(url):
    if urlparse.urlparse(url).scheme == '': # local file
        return (json.load(open(url)), url)
    #else
    network_res = urllib2.urlopen(url)
    json_content = json.load(network_res)
    return (json_content, network_res.geturl())

def run(options, args):
    if len(args) < 1: raise cli.Error("Virtual Appliance description file(json) must be specified.")

    vainfo_url = args[0]
    vmname = options.name
    vgname = options.vg
    size = options.size
    ram = options.ram
    extractOnly = options.extract_only
    copyPubKey = options.copy_pubkey
    leaveOnFail = options.leave_on_fail

    if vainfo_url.endswith(".tar.xz"):
        basename = os.path.basename(vainfo_url)
        if '-' not in basename: raise cli.Error("Could not determine VA ID from the filename.")
        vainfo = {
            "id" :basename.split('-')[0],
            "minimum_hd" : 1,
            "minimum_ram" : 128,
            "tarball": vainfo_url
        }
        vainfo_origin = None
    else: # assumes json
        vainfo, vainfo_origin = load_json(vainfo_url)

    if vmname is None: vmname = determineVmNameFromVaId(vainfo["id"])
    if size is None: size = vainfo["minimum_hd"]
    if ram is None: ram = vainfo["minimum_ram"]
    if vgname is None: vgname = determineMostCapableVolumeGroup()
    vasource = relative_path.resolve(vainfo_origin, vainfo["tarball"]) if vainfo_origin else vainfo["tarball"]
    print "Source tarball: %s" % vasource
    decompressOption = determineTarDecompressOptionBySuffix(vasource)
    
    s = system.getSystem()
    
    if not s.isStreamSourceAvailable(vasource): raise cli.Error("Source file '%s' is not available." % vasource)
    
    deviceName = s.createLogicalVolume(vgname,vmname,size,"@wbvm")
    print "Logical volume %s created." % deviceName
    xfs = s.getFilesystem("xfs")
    xfs.mkfs(deviceName)
    print "Logical volume formatted with XFS."
    print "Decompression option is: %s" % decompressOption

    v = vm.getVirtualMachineManager()
    try:
        with s.temporaryMount(deviceName, None, "inode32") as tmpdir:
            print "Mounted: %s" % tmpdir
            with s.openProcessForOutput("tar xvpf - %s -C %s" % (decompressOption, tmpdir)) as tar:
                with s.openInputStream(vasource) as (src, size):
                    buf = src.read(1024)
                    while buf != "":
                        tar.write(buf)
                        buf = src.read(1024)

            # カーネル種別(なし/32bit/64bit)判定
            kernel = v.determineVMKernel(tmpdir)
            if kernel == None: kernel = system.guest_kernel

            if not extractOnly:
                pass
            # ホスト名をつける
            v.setHostName(tmpdir, vmname)
            
            # 必要ならssh鍵のコピーを行う
            if copyPubKey:
                with v.openRootUserAuthorizedKeysForAppend(tmpdir) as authorizedKeys:
                    files = ("/root/.ssh/id_rsa.pub", "/root/.ssh/id_dsa.pub", "/root/.ssh/authorized_keys")
                    concat(files, authorizedKeys)

    except Exception, e:
        if not leaveOnFail: s.removeLogicalVolume(deviceName)
        raise e

    print "Creating Xen config file..."
    v.createVMConfigFile(vmname, ram, kernel, 1, deviceName)


    print "Done."
