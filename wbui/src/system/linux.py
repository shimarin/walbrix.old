# -*- coding: utf-8 -*-

'''
Created on 2011/05/01

@author: shimarin
'''

import subprocess
import os
import os.path
import sys
import stat
import time
import tempfile
import errno
import glob
if sys.version_info.major < 3:
    import urllib2
else:
    import urllib.request

import socket
import select
import traceback
import io # for StringIO

import struct
import fcntl
import array

import system

# ioctl requests
BLKGETSIZE=0x1260
BLKGETSIZE64=0x80081272
BLKSSZGET=0x1268
BLKPBSZGET=0x127b
FBIOGET_VSCREENINFO=0x4600
FBIOGET_FSCREENINFO=0x4602

class Filesystem:
    def mkfs(self, partition):
        pass
    def disableAutoFsck(self, partition):
        pass
    def label(self, partition, label):
        pass

class Ext2(Filesystem):
    def __init__(self, system):
        self.system = system
    
    def disableAutoFsck(self, partition):
        self.system.getShellOutput("tune2fs -i 0 -c 0 %s" % (partition))
    
    def mkfs(self, partition):
        if not self.system.isBlockSpecial(partition):
            raise Exception("%s is not a valid block device." % partition)
        self.system.execShell("mkfs.ext2 -q %s" % (partition), True)
        self.disableAutoFsck(partition)

    def label(self, partition, value):
        self.system.execShell("e2label %s %s" % (partition, value), True)

class Ext4(Ext2):
    def __init__(self, system):
        Ext2.__init__(self, system)
    
    def mkfs(self, partition):
        self.system.execShell("mkfs.ext4 %s" % (partition), True)
        self.disableAutoFsck(partition)

class Xfs(Filesystem):
    def __init__(self, system):
        self.system = system
    
    def mkfs(self, partition):
        self.system.execShell("mkfs.xfs -m crc=0 -f %s" % (partition), True)

    def label(self, partition, value):
        self.system.execShell("xfs_admin -L %s %s" % (value, partition), True)
    

class TemporaryMount:
    def __init__(self, system, partition, mount_point = None, mount_options = None):
        self.system = system
        self.partition = partition
        self.mount_point = mount_point
        self.mount_options = mount_options
    
    def __enter__(self):
        self.real_mount_point = self.mount_point if self.mount_point != None else tempfile.mkdtemp()
        options = ""
        if self.partition in ("/dev/shm", "tmpfs"): options = "-t tmpfs" 
        if self.mount_options != None: options += " -o %s" % self.mount_options
        mount_cmd = "mount %s %s %s" % (options, self.partition, self.real_mount_point)
        self.system.execShell(mount_cmd, True)
        return self.real_mount_point

    def __exit__(self, exc_type, exc_value, traceback):
        result = self.system.execShell("umount %s" % (self.real_mount_point))
        if self.mount_point is None: os.rmdir(self.real_mount_point)
        if exc_type: return False
        return True

class TemporaryFile:
    def __init__(self):
        pass
    def __enter__(self):
        (val, self.name) = tempfile.mkstemp()
        return self.name
    def __exit__(self, exc_type, exc_value, traceback):
        os.unlink(self.name)
        if exc_type: return False
        return True

class Snapshot:
    def __init__(self, system, device_name, size = 1):
        self.system = system
        self.device_name = device_name
        self.size = size
    
    def __enter__(self):
        (vgname, lvname) = self.system.determineVGandLVnameFromDeviceName(self.device_name)
        snapshot_name = "%s-wb-%d" % (lvname, os.getpid())
        if snapshot_name is None: raise Exception("Failed to create a snapshot for device '%s'" % self.device_name)
        self.snapshot_name = "/dev/%s/%s" % (vgname, snapshot_name)
        self.system.execShell("lvcreate --yes --snapshot --size=%dG --name %s %s >/dev/null" % (self.size, snapshot_name, self.device_name))
        return self.snapshot_name
    
    def __exit__(self, exc_type, exc_value, traceback):
        self.system.removeLogicalVolume(self.snapshot_name)
        if exc_type: return False
        return True

class InputStream:
    def __init__(self, urlOrFilename):
        self.urlOrFilename = urlOrFilename
        self.source = None
        self.length = None
    
    def __enter__(self):
        if self.urlOrFilename.startswith("http://") or self.urlOrFilename.startswith("https://"):
            if sys.version_info.major < 3:
                try:
                    self.source = urllib2.urlopen(self.urlOrFilename)
                except urllib2.HTTPError as e:
                    raise IOError(e)
            else: # python3
                try:
                    self.source = urllib.request.urlopen(self.urlOrFilename)
                except urllib.request.HTTPError as e:
                    raise IOError(e)
            contentLength = self.source.headers.getheader("Content-length")
            if contentLength is not None: self.length = int(contentLength)
        else:
            try:
                self.length = os.path.getsize(self.urlOrFilename)
                self.source = open(self.urlOrFilename)
            except OSError as e:
                raise IOError(e)
        return self.source, self.length

    def __exit__(self, exc_type, exc_value, traceback):
        if self.source is not None: self.source.close()
        if exc_type: return False
        return True

class Process:
    def __init__(self, cmdline):
        self.cmdline = cmdline
        self.process = None
        self.stream = None

    def __exit__(self, exc_type, exc_value, traceback):
        if self.stream is not None: self.stream.close()
        if self.process is not None:
            rst = self.process.wait()
            if rst != 0:
                stderr = self.process.stderr.read().strip()
                self.process.stderr.close()
                raise Exception(stderr)
        if exc_type: return False
        return True
    

class ProcessForInput(Process):
    def __init__(self, cmdline):
        Process.__init__(self, cmdline)
    
    def __enter__(self):
        self.process = subprocess.Popen(self.cmdline, shell=True, stdout=subprocess.PIPE,close_fds=True)
        self.stream = self.process.stdout
        return self.stream

class ProcessForOutput(Process):
    def __init__(self, cmdline):
        Process.__init__(self, cmdline)

    def __enter__(self):
        self.process = subprocess.Popen(self.cmdline, shell=True, stdin=subprocess.PIPE,close_fds=True)
        self.stream = self.process.stdin
        return self.stream

class CancellableProcessForInput:
    def __init__(self, cmdline):
        self.cmdline = cmdline
        self.process = None

    def __enter__(self):
        self.process = subprocess.Popen(self.cmdline, shell=False, stdout=subprocess.PIPE,stderr=subprocess.PIPE,close_fds=True)
        return self.process
    def __exit__(self, exc_type, exc_value, traceback):
        if exc_type:
            if self.process is not None:
                self.process.stdout.close()
                self.process.terminate()
            return False
        if self.process is not None: 
            self.process.stdout.close()
            rst = self.process.wait()
            if rst == -15 or rst == -2 or rst == 130: raise system.ProcessCancelled("Cancelled.")
            elif rst == -9: raise system.ProcessKilled("Killed.")
            elif rst != 0:
                #print rst
                stderr = self.process.stderr.read().strip()
                self.process.stderr.close()
                raise Exception(stderr.decode("utf-8"))
        return True

class WbForInput(CancellableProcessForInput):
    def __init__(self, subcommand, args = None):
        cmdline = [ "/usr/sbin/wb", subcommand ]
        if args != None: cmdline += args
        CancellableProcessForInput.__init__(self, cmdline)

class NonblockingReader:
    def __init__(self, stream):
        self.stream = stream
        self.buf = None
        self.eof = False
        self.block_allowed = False
    def _read(self):
        if self.buf == None: self.buf = io.BytesIO()
        if self.eof: return
        if self.block_allowed:
            c = self.stream.read()
            if (len(c) > 0): self.buf.write(c)
            else: self.eof = True
            return
        while select.select([self.stream],[],[], 0) != ([],[],[]):
            c = self.stream.read(1)
            if (len(c) > 0):
                self.buf.write(c)
            else:
                self.eof = True
                break

    def allowBlock(self, block_allowed = True):
        self.block_allowed = block_allowed

    def read(self, size = None):
        self._read()
        if size == None:
            if len(self.buf.getvalue()) == 0: return "" if self.eof else None
            str = self.buf.getvalue()
            self.buf = None
            return str
        else:
            if len(self.buf.getvalue()) >= size:
                self.buf.seek(0)
                str = self.buf.read(size)
                self.buf = io.BytesIO(self.buf.read())
                return str
        #else
        return None

    def readline(self):
        # TODO: EOF support!!
        self._read()
        if '\n' in self.buf.getvalue():
            (str, rest) = self.buf.getvalue().split(b'\n', 1)
            self.buf = io.BytesIO(rest)
            return str + b'\n'
        elif self.eof:
            return self.buf.read()
        #else
        return None

class SuppressStdout:
    def __init__(self):
        self.null_fd = os.open(os.devnull,os.O_RDWR)
        self.save_fd = os.dup(1)
    def __enter__(self):
        os.dup2(self.null_fd,1)
    def __exit__(self,*_):
        os.dup2(self.save_fd,1)
        os.close(self.null_fd)

class System:
    '''
    classdocs
    '''

    def __init__(self):
        self.filesystems = {"ext2":Ext2(self), "ext4": Ext4(self), "xfs": Xfs(self) }
        self.cacheDir = "/var/cache/wb"

    def getFilesystem(self, fsname):
        return self.filesystems[fsname]

    def getFilesystemFromDevice(self, device):
        fsname = subprocess.check_output("lsblk -rn -o FSTYPE %s" % device, shell=True, close_fds=True).strip()
        return self.getFilesystem(fsname)

    def getArchitectureString(self):
        return os.uname()[4]

    def checkIfArchitectureIsSupported(self, required_arch):
        supported_arch = {"i686":["i686"], "x86_64":["i686", "x86_64"]}
        arch = self.getArchitectureString()
        if arch not in supported_arch: return False
        if required_arch not in supported_arch[arch]: return False
        return True

    def getFreeMemoryInKb(self):
        return subprocess.check_output("free | grep 'Mem:'|awk '{print ($4+$6+$7)}'", shell=True, close_fds=True).rstrip()

    def execShell(self, cmd, raiseIfFail=False):
        result = subprocess.Popen(cmd, shell=True, close_fds=True).wait()
        if raiseIfFail and result != 0: raise Exception(cmd)
        # else
        return result

    def getShellOutput(self, cmd):
        return subprocess.check_output(cmd, shell=True, close_fds=True)

    def eject(self, device):
        self.execShell("eject %s" % (device))

    def determineBlockdeviceSize(self, device):
        with open(device, "r") as dev:
            dev.seek(0, 2)
            return dev.tell()

    def listAvailableDisks(self):
        #lshw = subprocess.Popen("lshw -xml -disable usb -disable cpuid -disable pci -disable pcilegacy -disable network -disable dmi -class disk|sed '2i <d>'|sed '$a </d>'", shell=True, stdout=subprocess.PIPE, close_fds=True)
        #nodes = xml.etree.ElementTree.parse(lshw.stdout).findall("/node")
        #lshw.wait()

        mounted_vols = []
        with open("/proc/mounts") as mounts:
            line = mounts.readline()
            while line:
                dev = line.split(" ")[0]
                if dev and dev.startswith("/dev/"): mounted_vols.append(dev)
                line = mounts.readline()

        def is_appropriate_device(logicalname):
            # 物理的デバイスでないものは除外
            if not os.path.isdir("/sys/block/%s/device" % logicalname): return False
            # リードオンリーは除外
            if open("/sys/block/%s/ro" % logicalname,"r").read().strip() != "0": return False
            # リムーバブルかつ SCSI diskでないものは除外
            if open("/sys/block/%s/removable" % logicalname,"r").read().strip() != "0" and not logicalname.startswith("sd"): return False
            # マウントされているボリュームを含んでる奴は除外
            if any(self.partitionBelongsTo(x, "/dev/" + logicalname) for x in mounted_vols): return False
            return True

        disks = []
        with self.openProcessForInput("lsblk -dnr -o NAME,LOG-SEC,SIZE,MODEL") as lsblk:
            line = lsblk.readline()
        
            while line:
                splitted = line.split(" ", 3)
                logicalname = splitted[0]
                if is_appropriate_device(logicalname):
                    sectorSize = int(splitted[1])
                    size = splitted[2]
                    product = splitted[3].rstrip().replace("\\x20", " ")
                    disks.append({"product":product,"logicalname":logicalname,"size":size,"sectorSize":sectorSize})
    
                line = lsblk.readline()
        
        return disks    

    def deactivateVolumeGroups(self, raiseOnFail=True):
        self.execShell("vgchange -an", raiseOnFail)
    
    def executePartedCommand(self, command, device):
        self.execShell("parted --script %s '%s'" % (device, command), True)
    
    def createFdiskPartitionTable(self, device):
        self.executePartedCommand("mklabel msdos", device)

    def createEFIPartitionTable(self, device):
        self.executePartedCommand("mklabel gpt", device)

    def createPrimaryPartition(self, device, start, end):
        self.executePartedCommand("mkpart primary %s %s" % (start, end), device)

    def toggleBootFlag(self, device, partitionNumber):
        self.executePartedCommand("toggle %d boot" % (partitionNumber), device)
    
    def setLVMFlag(self, device, partitionNumber, on=True):
        self.executePartedCommand("set %d lvm %s" % (partitionNumber, "on" if on else "off"), device)
    
    def waitForDevice(self, deviceName):
        count = 0
        while not os.path.exists(deviceName):
            time.sleep(1)
            count += 1
            if count >= 10: return False
        time.sleep(1)
        return True

    def createPhysicalVolume(self, partition):
        self.getShellOutput("pvcreate -ffy %s" % (partition))
    
    def createVolumeGroup(self, vgname, partitions, tag=None, pvTag=None):
        addtagopt = "--addtag=%s" % (tag) if tag != None else ""
        if not hasattr(partitions, '__iter__'): devices = [partitions]
        device_names = " ".join(devices)
        self.getShellOutput("vgcreate --yes %s %s %s" % (addtagopt, vgname, device_names))
        if pvTag is not None:
            for device in devices:
                self.getShellOutput("pvchange --addtag=%s %s" % (pvTag, device))
    
    def createLogicalVolume(self, vgname, lvname, size, tag=None):
        addtagopt = "--addtag=%s" % (tag) if tag != None else ""
        self.execShell("lvcreate --yes %s -n %s -L %dG %s" % (addtagopt, lvname, size, vgname), True)
        return "/dev/%s/%s" % (vgname, lvname)

    def createLogicalVolumeInMB(self, vgname, lvname, size, tag=None):
        addtagopt = "--addtag=%s" % (tag) if tag != None else ""
        self.execShell("lvcreate --yes %s -n %s -L %dM %s" % (addtagopt, lvname, size, vgname), True)
        return "/dev/%s/%s" % (vgname, lvname)
    
    def removeLogicalVolume(self, deviceName, retry=2):
        while retry > 0:
            if self.execShell("lvremove -f %s >/dev/null" % (deviceName), False) == 0: return
            #else
            time.sleep(3)
            retry -= 1

        self.execShell("lvremove -f %s" % (deviceName), True)

    def getLogicalVolumeStatusFlags(self, devicename):
    	return subprocess.check_output(("lvs","--noheadings","-o","Attr",devicename), shell=False, close_fds=True).strip()
    
    def reloadVolumeGroups(self):
        self.getShellOutput("vgscan")

    def listVolumeGroups(self, tag=None):
        if tag is not None and not tag.startswith("@"): raise Exception("Tag must be started with '@'")
        vglist = []
        tagStr = "" if tag is None else tag
        with self.openProcessForInput("vgs --units=g --nosuffix --noheadings %s" % tagStr) as vgs:
            line = vgs.readline() 
            while line:
                splitted = line.split()
                vginfo = {"name":splitted[0], "pv":int(splitted[1]), "lv":int(splitted[2]), "size":float(splitted[5]), "free":float(splitted[6]) }
                vglist.append(vginfo)
                line = vgs.readline()
        return vglist
    
    def listLogicalVolumes(self, tag=None):
        if tag is not None and not tag.startswith("@"): raise Exception("Tag must be started with '@'")
        lvlist = []
        tagStr = "" if tag is None else tag
        with self.openProcessForInput("lvs --units=g --nosuffix --noheadings %s" % tagStr) as lvs:
            line = lvs.readline() 
            while line:
                splitted = line.split()
                vginfo = {"name":splitted[0], "vg":splitted[1], "attr":splitted[2], "size":float(splitted[3]) }
                lvlist.append(vginfo)
                line = lvs.readline()
        return lvlist

    def getVolumeGroupNameCandidate(self, name, max=10):
        vgs = self.listVolumeGroups()
        vgmap = {}
        for vg in vgs:
            vgmap[vg["name"]] = vg

        for i in range(0,max):
            vgname = name
            if i > 0: vgname += str(i)
            if not vgname in vgmap: return vgname
        
        return None

    
    def determineVGandLVnameFromDeviceName(self, device_name):
        with self.openProcessForInput("lvs --noheadings --separator='|' %s" % (device_name)) as lvs:
            line = lvs.readline()
            if line == None: return None
            splitted = line.split('|')
            return (splitted[1].strip(), splitted[0].strip())
    
    def determinePartitionUuid(self, partition):
        blkid = subprocess.Popen("blkid -o value -s UUID %s" % (partition), shell=True, stdout=subprocess.PIPE, close_fds=True)
        uuid = blkid.stdout.read().strip()
        if blkid.wait() != 0: return None
        return uuid if uuid != "" else None

    def grub2exists(self):
        GRUB2_INSTALLER = "/usr/sbin/grub-install"
        if os.path.exists(GRUB2_INSTALLER) and (stat.S_IXUSR & os.stat(GRUB2_INSTALLER)[stat.ST_MODE]): #grub2
            return True
        #else
        return False

    def installGrub(self, device, targetDir):
        self.getShellOutput("grub-install --target=i386-pc --recheck --boot-directory=%s/boot %s" % (targetDir,device))

    def installGrubEFI(self, targetDir):
        if not os.path.isdir("%s/EFI/BOOT" % targetDir):
            os.makedirs("%s/EFI/BOOT" % targetDir)
        self.execShell("grub-mkimage -o %s/EFI/BOOT/bootx64.efi -O x86_64-efi xfs fat part_gpt part_msdos normal linux echo all_video test multiboot multiboot2 search iso9660 gzio lvm chain configfile cpuid minicmd gfxterm font terminal" % targetDir)

    def isBlockSpecial(self, device):
        if not os.path.exists(device): return False
        mode = os.stat(device)[stat.ST_MODE]
        return stat.S_ISBLK(mode)

    def isLogicalVolume(self, device):
        rdev = os.stat(device).st_rdev
        uuid_file = "/sys/dev/block/%d:%d/dm/uuid" % (os.major(rdev), os.minor(rdev))
        if not os.path.isfile(uuid_file): return False
        return open(uuid_file).read().startswith("LVM-")

    def temporaryMount(self, partition, mountPoint=None, mountOptions=None):
        return TemporaryMount(self, partition, mountPoint, mountOptions)

    def temporaryFile(self):
        return TemporaryFile()
    
    def openInputStream(self, urlOrFilename):
        return InputStream(urlOrFilename)
    
    def isStreamSourceAvailable(self, urlOrFilename):
        if urlOrFilename.startswith("http://") or urlOrFilename.startswith("https://"):
            return True
        # else
        return os.path.isfile(urlOrFilename)

    def openProcessForInput(self, cmdline):
        return ProcessForInput(cmdline)
    
    def openProcessForOutput(self, cmdline):
        return ProcessForOutput(cmdline)

    def openCancellableProcessForInput(self, cmdline):
        return CancellableProcessForInput(cmdline)

    def openWbForInput(self, subcommand, args = None):
        return WbForInput(subcommand, args)

    def getNonblockingReader(self, stream):
        return NonblockingReader(stream)
    
    def openSnapshot(self, deviceName, size):
        return Snapshot(self, deviceName, size)

    def reboot(self):
        # utmpが無い場合ramdisk起動（インストーラ）とみなし強制halt
        shouldBeCareful = os.path.isfile("/var/run/utmp")
        self.execShell("reboot" if shouldBeCareful else "reboot -f")
        exit()
    
    def initializeZram(self, size, zramNumber=0):
        with open("/sys/block/zram%d/disksize" % (zramNumber), "w") as disksize:
            disksize.write("%d" % (size))
        with open("/sys/block/zram%d/disksize" % (zramNumber), "r") as disksize:
            verify = int(disksize.read())

        with open("/sys/block/zram%d/dev" % (zramNumber), "r") as devfile:
            devnum = devfile.read().strip()

        deviceName = "/dev/zram%d" % (zramNumber)

        if not os.path.exists(deviceName):
            spdevnum = devnum.split(':')
            major = int(spdevnum[0])
            minor = int(spdevnum[1])
            os.mknod(deviceName, 0o660 | stat.S_IFBLK,os.makedev(major,minor))

        if verify < size: raise Exception("Unexpected %s disksize %d(expected:%d)" % (deviceName, verify, size))

        try:
            verify = self.determineBlockdeviceSize(deviceName)
        except:
            raise Exception("Blockdevice size couldn't be determined: %s - %s" % (deviceName, devnum))

        if verify < size:
            raise Exception("Unexpected %s disksize %d(expected:%d)" % (deviceName, verify, size))

        return deviceName
    
    def resetZram(self, zramNumber=0):
        with open("/sys/block/zram%d/reset" % (zramNumber), "w") as reset:
            reset.write("1")

    def getFreeMemoryInKB(self):
        return int(subprocess.Popen("free | grep 'Mem:'|awk '{print ($4+$6+$7)}'", shell=True, stdout=subprocess.PIPE,close_fds=True).stdout.readline().rstrip())
    def getHostname(self):
        return socket.gethostname()

    def getExecutableBitWidth(self, filename):
        ei_class = None
        with open(filename, "rb") as f:
            if f.read(1) != b'\177' or f.read(3) != b"ELF":
                raise Exception
            ei_class = struct.unpack('B', f.read(1))[0]
        if ei_class == 1: return 32
        elif ei_class == 2: return 64
        #else
        raise Exception("Neither 32/64 bit")

    def getDeviceFSType(self, device):
        if not self.isBlockSpecial(device): return None
        return subprocess.check_output("lsblk -n -o FSTYPE %s" % device, shell=True, close_fds=True).rstrip()

    def determineLogicalVolumeSizeInGB(self, device):
        return float(subprocess.check_output("lvs %s --noheadings --units g -o lv_size --nosuffix" % device, shell=True, close_fds=True))

    def doesCPUSupport64BitMode(self):
        return "lm" in subprocess.check_output("grep -m 1 'flags' /proc/cpuinfo", shell=True, close_fds=True).strip().split(' ')

    def getKernelVersionString(self, filename):
        ver = ""
        with open(filename) as f:
            f.seek(526,0)
            f.seek(struct.unpack('<H', f.read(2))[0] + 0x200,0)
            c = f.read(1)
            while c and c != '\0' and c != ' ':
                ver += c
                c = f.read(1)
        return ver

    def getFrameBufferIdString(self):
        if not os.path.exists("/dev/fb0"): return None
        try:
            fd = os.open("/dev/fb0", os.O_RDONLY)
        except:
            return None
        try:
            var = array.array('c', [chr(0)] * 80)
            fcntl.ioctl(fd, FBIOGET_FSCREENINFO, var, 1)
            return var[:16].tostring()
        finally:
            os.close(fd)

    def determineFrameBufferBitDepth(self):
        if not os.path.exists("/dev/fb0"): return None
        try:
            fd = os.open("/dev/fb0", os.O_RDONLY)
        except:
            return None
        try:
            var = array.array('B', [0] * 160)
            fcntl.ioctl(fd, FBIOGET_VSCREENINFO, var, 1)
            return var[24] # little endian only
        finally:
            os.close(fd)

    def getTtyName(self):
        try:
            return os.ttyname(0)
        except:
            return None

    def isRunningAsGetty(self):
        return self.getTtyName() == "/dev/console" # and os.getppid() == 1

    def getSystemKeymap(self):
        echo = subprocess.Popen("source /etc/conf.d/keymaps && echo $keymap", shell=True, stdout=subprocess.PIPE, close_fds=True)
        keymap = echo.stdout.read()
        if echo.wait() != 0: return None
        if keymap != None: keymap = keymap.strip()
        return keymap

    def suppressStdout(self):
        return SuppressStdout()

    def ioctl_read_uint32(self, fd, req):
        buf = array.array('c', [chr(0)] * 4)
        fcntl.ioctl(fd, req, buf)
        return struct.unpack('I',buf)[0]

    def ioctl_read_uint64(self, fd, req):
        buf = array.array('c', [chr(0)] * 8)
        fcntl.ioctl(fd, req, buf)
        return struct.unpack('L',buf)[0]

    def isBiosCompatibleDisk(self, device):
        fd = os.open(device, os.O_RDONLY)
        try:
            logical_sector_size = self.ioctl_read_uint32(fd, BLKSSZGET)
            try:
                device_size = self.ioctl_read_uint64(fd, BLKGETSIZE64)
            except IOError as e: # Some platform doesn't support BLKGETSIZE64
                if e.errno in (errno.EINVAL,errno.ENOTTY):
                    device_size = self.ioctl_read_uint32(fd, BLKGETSIZE) * logical_sector_size
                else: raise
        finally:
            os.close(fd)

        return (logical_sector_size == 512 and device_size <= 2199023255552) # 512 * 2**32

    def getLogicalSectorSize(self, device):
        fd = os.open(device, os.O_RDONLY)
        try:
            return self.ioctl_read_uint32(fd, BLKSSZGET)
        finally:
            os.close(fd)

    def getPhysicalSectorSize(self, device):
        fd = os.open(device, os.O_RDONLY)
        try:
            return self.ioctl_read_uint32(fd, BLKPBSZGET)
        finally:
            os.close(fd)

    def isSameDevice(self, device1, device2):
        return os.stat(device1).st_rdev == os.stat(device2).st_rdev

    def getDiskFromPartition(self, partition):
        if isinstance(partition, tuple):
            major, minor = partition
        else: # expect str
            partition_rdev = os.stat(partition).st_rdev
            major, minor = (os.major(partition_rdev), os.minor(partition_rdev))
        for dev in glob.glob("/sys/dev/block/*/*/dev"):
            if open(dev, "r").read().strip() == "%d:%d" % (major, minor):
                rdev = open(os.path.normpath(os.path.join(os.path.dirname(dev), "../dev")), "r").read().strip()
                return os.path.normpath(os.path.join("/dev/block",os.readlink("/dev/block/%s" % rdev)))
        return None

    def partitionBelongsTo(self, partition, disk):
        discovered_disk = self.getDiskFromPartition(partition)
        if discovered_disk and self.isSameDevice(disk, discovered_disk):
            return True
        partition_rdev = os.stat(partition).st_rdev
        for dev in glob.glob("/sys/dev/block/%d:%d/slaves/*/dev" % (os.major(partition_rdev), os.minor(partition_rdev))):
            major, minor = map(lambda x:int(x), open(dev).read().strip().split(':'))
            discovered_disk = self.getDiskFromPartition((major, minor))
            if discovered_disk and self.isSameDevice(disk, discovered_disk):
                return True

    def getPartition(self, disk, number):
        disk_rdev = os.stat(disk).st_rdev
        for partition in glob.glob("/sys/dev/block/%d:%d/*/partition" % (os.major(disk_rdev), os.minor(disk_rdev))):
            if int(open(partition, "r").read().strip()) == number:
                rdev = open(os.path.join(os.path.dirname(partition), "dev"), "r").read().strip()
                return os.path.normpath(os.path.join("/dev/block",os.readlink("/dev/block/%s" % rdev)))
        return None

    def syncUdev(self):
        #time.sleep(5)
        return self.execShell("udevadm settle") == 0

