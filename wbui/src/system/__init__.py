# -*- coding: utf-8 -*-

import system.linux

_lang = None
_region = None
system = system.linux.System()

def setSystem(_system):
    global system
    system = _system

def getSystem():
    return system

def lang():
    global _lang
    if _lang == None:
        if os.path.isfile("/etc/wb/language"):
            with open("/etc/wb/language") as f:
                _lang = f.read().strip()
        if _lang == None or _lang == "": _lang = "ja"
    return _lang

def region():
    global _region
    if _region == None:
        if os.path.isfile("/etc/wb/region"):
            with open("/etc/wb/region") as f:
                _region = f.read().strip()
        if _region == None or _region == "": _region = "jp"
    return _region

########## Compatibility code below ###########

import subprocess
import os
import stat
try:
    import urllib2
except:
    import urllib.request
import socket
import struct
import fcntl
import shutil
import tempfile
from xml.etree import ElementTree

# WBUIバージョン
version = "0.3.0"

guest_kernel = "/boot/vmlinuz.domU"
runapp_link = "/var/run/wb-run-app"
cache_dir = "/var/cache/wb"

class ProcessCancelled(Exception):
    def __init__(self, message):
        Exception.__init__(self, message)

class ProcessKilled(Exception):
    def __init__(self, message):
        Exception.__init__(self, message)

def is_block_special(device_name):
    mode = os.stat(device_name)[stat.ST_MODE]
    return stat.S_ISBLK(mode)

def is_iso9660(device_name):
    if not os.path.exists(device_name) or not is_block_special(device_name): return False
    blkid = subprocess.Popen("blkid -o value -s TYPE /dev/scd0", shell=True, stdout=subprocess.PIPE, close_fds=True)
    type = blkid.stdout.read().strip()
    if blkid.wait() != 0: return False
    return type == "iso9660"

def cdrom_file_exists(name):
    if not is_iso9660("/dev/scd0"): return False

    isoinfo = subprocess.Popen("isoinfo dev=/dev/scd0 -R -f", shell=True, stdout=subprocess.PIPE, close_fds=True)
    line = isoinfo.stdout.readline()
    while line:
        if line == name + "\n":
            return True
        line = isoinfo.stdout.readline()
    isoinfo.wait()
    return False

def open_cdrom_file_reader_process(name):
    return subprocess.Popen("isoinfo dev=/dev/scd0 -R -x %s" % (name), shell=True, stdout=subprocess.PIPE, close_fds=True)

def determine_cdrom_filesize(name):
    dirname = os.path.dirname(name)
    if not dirname.endswith("/"):
        dirname += "/"
    basename = os.path.basename(name)
    isoinfo = subprocess.Popen("isoinfo dev=/dev/scd0 -R -l", shell=True, stdout=subprocess.PIPE, close_fds=True)
    line = isoinfo.stdout.readline()
    while line:
        if line == "Directory listing of " + dirname + "\n":
            break;
        line = isoinfo.stdout.readline()

    if line == "":
        isoinfo.wait()
        return None

    line = isoinfo.stdout.readline()
    while line:
        if line == "\n":
            break
        if line[72:] == basename + "\n":
            isoinfo.wait()
            return int(line[36:46])
        line = isoinfo.stdout.readline()

    isoinfo.wait()
    return None

def exec_shell(cmd):
    return subprocess.Popen(cmd, shell=True, close_fds=True).wait()

def create_physical_volume(device_name):
    if exec_shell("pvcreate -ffy %s" % device_name) != 0:
        raise Exception("system.create_physical_volume.pvcreate")

def create_volume_group(vgname, devices, tag=None, pv_tag=None):
    addtagopt = "--addtag=%s" % (tag) if tag != None else ""
    if not hasattr(devices, '__iter__'):
        devices = [devices]
    device_names = " ".join(devices)
    if exec_shell("vgcreate %s %s %s" % (addtagopt, vgname, device_names)) != 0:
        raise Exception("system.create_volume_group.vgcreate")            

    if pv_tag != None:
        for device in devices:
            exec_shell("pvchange --addtag=%s %s" % (pv_tag, device))

def create_logical_volume_in_GB(vgname, name, size, mkfs=False, tag=None):
    addtagopt = "--addtag=%s" % (tag) if tag != None else ""

    ret = exec_shell("lvcreate --yes %s -n %s -L %dG %s" % (addtagopt, name, size, vgname))
    if ret != 0: return None

    device_name = "/dev/%s/%s" % (vgname, name)
    if mkfs == None or mkfs == False: return device_name

    fstype = "xfs" if mkfs == True else mkfs
    if fstype == "xfs":
        ret = exec_shell("mkfs.xfs -m crc=0 -f %s" % device_name)
    else:
        ret = exec_shell("mkfs.%s -q %s" % (fstype, device_name))

    if ret != 0:
        remove_logical_volume(device_name)
        return None

    return device_name

def remove_logical_volume(device_name):
    if exec_shell("dmsetup remove `readlink %s`" % (device_name)) != 0:
        return False
    if exec_shell("lvremove -f %s" % (device_name)) != 0:
        return False
    os.unlink(device_name)
    return True

def determine_device_uuid(logicalname):
    blkid = subprocess.Popen("blkid -o value -s UUID %s" % (logicalname), shell=True, stdout=subprocess.PIPE, close_fds=True)
    uuid = blkid.stdout.read().strip()
    if blkid.wait() != 0: return None
    return uuid if uuid != "" else None

def create_cache_dir_if_not_exists():
    if not os.path.isdir(cache_dir):
        if os.path.exists(cache_dir):
            raise Exception("Couldn't create cache directory %s" % (cache_dir))
        else:
            os.mkdir(cache_dir)

def get_ip_address(ifname):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    return socket.inet_ntoa(fcntl.ioctl(
            s.fileno(),
            0x8915,  # SIOCGIFADDR
            struct.pack('256s', ifname[:15])
            )[20:24])

def get_ip_address_which_reaches_default_gateway():
    if not os.path.isfile("/proc/net/route"): return None
    with open("/proc/net/route", "r") as routes:
        line = routes.readline()
        if not line: return None
        line = routes.readline()
        while line:
            cols = line.split()
            if len(cols) > 2:
                ifname = cols[0]
                destination = cols[1]
                if destination == "00000000":
                    return get_ip_address(ifname)

            line = routes.readline()
    return get_ip_address("eth0")

def determine_tar_decompress_option_by_suffix(filename):
    if filename.endswith(".gz") or filename.endswith(".tgz"):
        return "-z"
    elif filename.endswith(".bz2") or filename.endswith(".tbz2"):
        return "-j"
    elif filename.endswith(".lzma"):
        return "--lzma"
    elif filename.endswith(".xz"):
        return "--xz"
    #else
    return ""

def get_metadata(device_name, mounted_path, filename):
    metadata_file = "%s/%s" % (mounted_path, filename)

    if not os.path.isfile(metadata_file): return None

    metadata = None
    with open(metadata_file, "r") as f:
        metadata = ElementTree.parse(f)

    if metadata == None: return None

    uuid = determine_device_uuid(device_name)
    if uuid != None:
        create_cache_dir_if_not_exists()
        shutil.copyfile(metadata_file, "%s/%s" % (cache_dir, uuid))

    return metadata

def get_va_metadata(device_name, mounted_path):
    return get_metadata(device_name, mounted_path, "/etc/wb-va.xml")

def get_app_metadata(device_name, mounted_path):
    return get_metadata(device_name, mounted_path, "/etc/wb-app.xml")

def get_metadata_from_cache(device_name):
    uuid = determine_device_uuid(device_name)
    if uuid == None: return None

    cache_file = "%s/%s" % (cache_dir, uuid)
    if not os.path.isfile(cache_file): return None

    with open(cache_file, "r") as f:
        return ElementTree.parse(f)

def load_xen_config_file(vmname):
    execfile("/etc/xen/" + vmname)
    _locals = locals()
    params = {}
    for _local in _locals:
        if not _local.startswith("__"):
            params[_local] = _locals[_local]
    return params

def determine_device_from_vmname(vmname):
    config = load_xen_config_file(vmname)
    if not "disk" in config: return None
    disk = config["disk"]
    if len(disk) < 1: return None
    first_disk = disk[0].split(',')[0]
    if not first_disk.startswith("phy:/dev/"): return None
    
    return first_disk[4:]

def send_stream_via_http(stream, location, content_type, host, port=8080):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((host,port))
    try:
        s.sendall("PUT %s HTTP/1.0\n" % (location))
        s.sendall("Content-Type: %s\n\n" % (content_type))
        buf = stream.read(1024)
        while buf != "":
            s.sendall(buf)
            buf = stream.read(1024)
    finally:
        s.close()

# アプリの一覧を得る
def get_apps():
    apps = []
    lvs = subprocess.Popen("lvs --noheadings --separator='|' @wbapp", shell=True, stdout=subprocess.PIPE,close_fds=True)
    line = lvs.stdout.readline() 
    while line:
        splitted = line.split('|')
        name = splitted[0].strip()
        vg = splitted[1].strip()
        apps.append({"name":name, "device":"/dev/%s/%s" % (vg, name)})
        line = lvs.stdout.readline() 
    return apps

def get_system_keymap():
    echo = subprocess.Popen("source /etc/conf.d/keymaps && echo $keymap", shell=True, stdout=subprocess.PIPE, close_fds=True)
    keymap = echo.stdout.read()
    if echo.wait() != 0: return None
    if keymap != None: keymap = keymap.strip()
    return keymap

def set_system_keymap(keymap):
    result = exec_shell("loadkeys %s" % (keymap))
    if result != 0: return False

    with open("/etc/conf.d/keymaps", "w") as f:
        f.write("# /etc/conf.d/keymaps\n")
        f.write("keymap=\"%s\"\n" % (keymap))
        f.write("windowkeys=\"NO\"\n")
        f.write("extended_keymaps=\"\"\n")
        f.write("dumpkeys_charset=\"\"\n")
        f.write("fix_euro=\"NO\"\n")

    return True

def determine_vg_and_lv_name_from_device_name(device_name):
    lvs = subprocess.Popen("lvs --noheadings --separator='|' %s" % (device_name), shell=True, stdout=subprocess.PIPE,close_fds=True)
    line = lvs.stdout.readline()
    lvs.stdout.close()
    if lvs.wait() != 0: return None
    if line == None: return None
    
    splitted = line.split('|')
    return (splitted[1].strip(), splitted[0].strip())

class Mount():
    def __init__(self, device_name, mount_point = None):
        self.device_name = device_name
        self.mount_point = mount_point

    def __enter__(self):
        self.real_mount_point = self.mount_point if self.mount_point != None else tempfile.mkdtemp()
        options = ""
        if self.device_name == "/dev/shm": options = "-t tmpfs" 
        mount_cmd = "mount %s %s %s" % (options, self.device_name, self.real_mount_point)
        if exec_shell(mount_cmd) != 0:
            raise Exception(mount_cmd)
        return self.real_mount_point

    def __exit__(self, exc_type, exc_value, traceback):
        result = exec_shell("umount %s" % (self.real_mount_point))
        if self.mount_point == None:
            os.rmdir(self.real_mount_point)
        if exc_type: return False
        return True

class Snapshot():
    def __init__(self, device_name, size = 1):
        self.device_name = device_name
        self.size = size
    
    def __enter__(self):
        (vgname, lvname) = determine_vg_and_lv_name_from_device_name(self.device_name)
        snapshot_name = "%s-wb-%d" % (lvname, os.getpid())
        self.snapshot_name = "/dev/%s/%s" % (vgname, snapshot_name)
        result = exec_shell("lvcreate --snapshot --size=%dG --name %s %s" % (self.size, snapshot_name, self.device_name))
        if result != 0: raise Exception("lvcreate --snapshot")
        return self.snapshot_name
    
    def __exit__(self, exc_type, exc_value, traceback):
        remove_logical_volume(self.snapshot_name)
        if exc_type: return False
        return True

class WBUIUpdate:
    
    def __init__(self, url = "http://hub.stbbs.net/wbui/update.xml"):
        self.url = url

    def load(self):
        if "urllib2" in sys.modules:
            update_xml_file = urllib2.urlopen(self.url)
        else:
            update_xml_file = urllib.request.urlopen(self.url)
        try:
            self.update_info = ElementTree.parse(update_xml_file)
        finally:
            update_xml_file.close()

    def get_latest_version_info(self):
        versions = self.update_info.findall("//version")
        if version == None or len(versions) == 0: return None
        return versions[0]

    def get_del_files(self, version):
        del_files = []
        for delete_elem in version.findall("delete"):
            filename = delete_elem.get("file")
            if filename != None:
                del_files.append(filename)
        return del_files
