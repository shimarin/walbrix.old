# -*- coding: utf-8 -*-

'''
Created on 2011/05/22

@author: shimarin
'''

import os
import sys
import re
import traceback
import subprocess
import json

import system

class Vm:
    def setHostName(self, rootdir, hostname):
        if os.path.isfile(rootdir + "/etc/hostname"):
            # debian方式というか一般的なUNIX方式
            with open(rootdir + "/etc/hostname", "w") as f:
                f.write(hostname)
            return True
        elif os.path.isfile(rootdir + "/etc/sysconfig/network"):
            # RedHad方式
            with open(rootdir + "/etc/sysconfig/network", "w") as f:
                f.write("NETWORKING=yes\nNETWORKING_IPV6=yes\nHOSTNAME=%s.local" % (hostname))
            return True
        elif os.path.isfile(rootdir + "/etc/conf.d/hostname"):
            # Gentoo方式
            with open(rootdir + "/etc/conf.d/hostname", "w") as f:
                f.write("hostname=\"%s\"" % (hostname))
            return True
    
        return False

    def openRootUserAuthorizedKeysForAppend(self, rootdir):
        root = "%s/root" % (rootdir)
        dot_ssh = "%s/.ssh" % (root)
        if os.path.exists(dot_ssh):
            if not os.path.isdir(dot_ssh): raise Exception(".ssh must be a directory!")
        else:
            if not os.path.exists(root): os.mkdir(root, 0700)
            os.mkdir(dot_ssh, 0700)
        return open("%s/authorized_keys" % (dot_ssh), "a")


class Xen(Vm):
    '''
    classdocs
    '''

    def __init__(self):
        '''
        Constructor
        '''

    def createVMConfigFile(self, hostname, memory, kernel, vcpus, device_name):
        use_pvgrub = "pv-grub-x86" in kernel
        with open("/etc/xen/" + hostname, "w") as f:
            f.write("name=\"%s\"\n" % (hostname))
            f.write("memory=%d\n" % (memory))
            f.write("kernel=\"%s\"\n" % (kernel))
            if use_pvgrub:
                f.write("extra=\"(hd0)/boot/grub/menu.lst\"\n")
            else:
                f.write("root=\"/dev/xvda1 ro\"\n")
            f.write("vcpus=%d\n" % (vcpus))
            f.write("disk=[ \"phy:%s,xvda1,w\" ]\n" % (device_name))
            f.write("vif=[\"\"]\n")
    
    def removeVMConfigFile(self, vmname):
        os.unlink("/etc/xen/" + vmname)
    
    def getVMConfig(self, vmname):
        configfile = "/etc/xen/" + vmname
        if not os.path.exists(configfile): raise Exception("Xen VM config file '%s' doesn't exist." % configfile)
        _locals = {}
        execfile(configfile, {}, _locals)
        params = {}
        for _local in _locals:
            if not _local.startswith("__"):
                params[_local] = _locals[_local]

        return params

    def getDeviceNameFromDeviceString(self, deviceString):
        first_disk = deviceString.split(',')[0]
        if not first_disk.startswith("phy:/dev/"): return None
        return first_disk[4:]

    def determineVMDeviceName(self, vmname):
        params = self.getVMConfig(vmname)
        if not "disk" in params: return None
        disk = params["disk"]
        if len(disk) < 1: return None
        return self.getDeviceNameFromDeviceString(disk[0])
    
    def listVMConfigs(self):
        # /etc/xen にある定義ファイル(except directories, executables, *.sxp, *.xml, README*, cpupool, xl.conf, )
        def vm_config_file_info(name):
            excludes = [r"\.sxp$",r"\.xml$",r"\.conf$",r"^README(\.|$)",r"^cpupool$",r"^xmexample",r"^xlexample"]
            if any(map(lambda x:re.search(x,name),excludes)): return None
            if not os.path.isfile(os.path.join("/etc/xen", name)): return None
            return {
                "name":name,
                "autostart":os.path.islink("/etc/xen/auto/%s" % name)
            }

        return filter(lambda x:x != None, map(lambda x:vm_config_file_info(x), os.listdir("/etc/xen")))

    def getDomains(self):
        domains = {}

        if os.path.isfile("/usr/sbin/xl"):
            # まずは稼働中のdomUを列挙
            xl = subprocess.Popen(("/usr/sbin/xl","list","-l"), shell=False, stdout=subprocess.PIPE, close_fds=True)
            out = xl.stdout.read()
            xl.stdout.close()
            if xl.wait() == 0:
                doms = json.loads(out)
            
                for domain in doms:
                    domid = domain["domid"]
                    name = domain["config"]["c_info"]["name"]
                    memory = domain["config"]["b_info"]["max_memkb"] / 1024
    
                    if name != None and domid != 0:
                        domains[name] = {"id":domid,"name":name,"memory":memory,"configfile":False,"autostart":False}
    
        # 次に /etc/xen にある定義ファイル(except directories, executables, *.sxp)
        if os.path.isdir("/etc/xen"):
            configfiles = os.listdir("/etc/xen")
            for domain_name in configfiles:
                if domain_name.endswith(".sxp") or domain_name == "qemu-ifup" or domain_name.endswith(".xml") or domain_name.startswith("README") or domain_name == "xl.conf" or domain_name == "cpupool" or domain_name.startswith("xmexample") or domain_name.startswith("xlexample") or domain_name == "oxenstored.conf":
                    continue
                fullpath = os.path.join("/etc/xen", domain_name)
                if os.path.isfile(fullpath) != True: continue
    
                if domain_name in domains:
                    domains[domain_name]["configfile"] = True
                else:
                    domains[domain_name] = {"name":domain_name,"configfile":True,"memory":None,"autostart":False}
    
        # 今度は @wbvmで孤児を捜す
        lvs = subprocess.Popen(["/sbin/lvs","--noheadings","--separator=|","@wbvm"], shell=False, stdout=subprocess.PIPE,close_fds=True)
        line = lvs.stdout.readline()
        while line:
            splitted = line.split('|')
            name = splitted[0].strip()
            vg = splitted[1].strip()
            device_name = "/dev/%s/%s" % (vg, name)
            if not name in domains:
                # configfileがFalseで deviceが存在する奴はorphan
                domains[name] = {"name":name,"memory":None,"configfile":False,"autostart":False,"device":device_name}
            line = lvs.stdout.readline()
    
        # ついでに @wbdrbdvm(TODO)
    
        # /etc/xen/autoを検索し、自動起動の状態を取得
        if os.path.isdir("/etc/xen/auto"):
            autofiles = os.listdir("/etc/xen/auto")
            for domain_name in autofiles:
                if domain_name in domains:
                    domains[domain_name]["autostart"] = True
    
        domains_arr = []
        for domain_name in domains:
            domain = domains[domain_name]
            domains_arr.append(domain)
    
        return domains_arr

    def startDomain(self, name):
        ret = os.system("xl create /etc/xen/%s" % (name))
        if ret != 0: raise Exception("xl create returned != 0")

    def startDomainAsync(self, name):
        return subprocess.Popen(["/usr/sbin/xl", "create", "/etc/xen/%s" % name], shell=False, close_fds=True)

    def determineVMKernel(self, path):
        if not os.path.isfile("%s/boot/grub/menu.lst" % path): return None
        
        s = system.getSystem()
        bw = s.getExecutableBitWidth("%s/sbin/init" % path)
        return "/usr/lib/xen/boot/pv-grub-x86_%d.gz" % bw

    def getFreeMemoryInMb(self):
        try:
            info = subprocess.Popen(("/usr/sbin/xl", "info"), shell=False, close_fds=True, stdout=subprocess.PIPE)
        except:
            return (None,None)
        fields = {}
        line = info.stdout.readline()
        while line:
            if ":" in line:
                (key,value) = line.split(':', 1)
                fields[key.strip()] = value.strip()
            line = info.stdout.readline()
        info.stdout.close()
        if info.wait() != 0: return (None,None)

        freememory = int(fields["free_memory"])
        maxmemory = int(fields["total_memory"])
        return (freememory, maxmemory)
