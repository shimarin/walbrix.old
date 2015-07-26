import argparse,os,sys,stat,subprocess,re,struct
import create_install_disk

def is_block(name):
    try:
        return stat.S_ISBLK(os.stat(name)[stat.ST_MODE])
    except OSError, e:
        if e.errno != os.errno.ENOENT: raise
    return False

def is_vm(device):
    with create_install_disk.tempmount(device, "ro") as tempdir:
        return any(map(lambda x:os.path.isfile(os.path.join(tempdir, x)), ["boot/grub/menu.lst","boot/grub/grub.cfg","sbin/init"]))

def make_sure_its_vm(device):
    if not is_vm(device): raise Exception("Specified device doesn't look like a VM storage")
    return True

def get_device_number(device):
    device_rdev = os.stat(device).st_rdev
    return (os.major(device_rdev), os.minor(device_rdev))

def make_sure_device_is_not_being_used(device):
    if not is_block(device): return

    device_number = get_device_number(device)
    for mounted_device in filter(lambda x:x.startswith("/dev/"), [x.split()[0] for x in open("/proc/mounts").readlines()]):
        if get_device_number(mounted_device) == device_number: raise Exception("Device %s is mounted" % device)

    try:
        if subprocess.check_output(["lvs","--noheadings","--nosuffix",device,"-o","lv_attr"], close_fds=True).strip()[5] == 'o': raise Exception("Device %s is being used" % device)
    except subprocess.CalledProcessError, e: # probably not LV
        pass

def get_device(name):
    for line in subprocess.check_output(["lvs","--noheadings","--nosuffix","@wbvm","-o","lv_name,lv_path"], close_fds=True).splitlines():
        lv, device = map(lambda x:x.strip(), line.split())
        if lv == name and make_sure_its_vm(device):
            print "VM found: %s" % device
            return device
    raise Exception("No such VM: %s" % name)

def detect_arch(executable):
    ei_class = None
    with open(executable, "rb") as f:
        if f.read(1) != b'\177' or f.read(3) != b"ELF": raise Exception("%s is not an ELF binary." % executable)
        ei_class = struct.unpack('B', f.read(1))[0]
    arch = {1:32,2:64}.get(ei_class)
    if arch is None: raise Exception("%s is neither 32/64 bit" % executable)
    print "Architecture determined from %s: %d-bit" % (executable, arch)
    return arch

def choose_bootloader(supported_archs):
    bootloaders = {
        "x86_64":"/usr/lib/xen/boot/pv-grub2-x86_64.gz",
        "i686":"/usr/lib/xen/boot/pv-grub2-x86_32.gz"
    }
    for arch in supported_archs:
        if arch in bootloaders and os.path.isfile(bootloaders[arch]): return bootloaders[arch]
    raise Exception("No applicable bootloader.")

def determine_boot_type(vmroot):
    init = os.path.join(vmroot, "sbin/init")
    grub1_cfg = os.path.join(vmroot, "boot/grub/menu.lst")
    grub2_cfg = os.path.join(vmroot, "boot/grub/grub.cfg")

    # pv-grub2
    if os.path.isfile(grub2_cfg):
        cfg_content = open(grub2_cfg).read()
        arch_line_match = re.search(r'^set\s*WALBRIX_DOMAIN_ARCH\s*=(.+)$', cfg_content, re.MULTILINE)
        if arch_line_match:
            supported_archs = arch_line_match.groups()[0]
            print "Supported architecture: %s" % supported_archs
            bootloader = choose_bootloader(supported_archs.split(','))
        else:
            bootloader = "/usr/lib/xen/boot/pv-grub2-x86_%d.gz" % detect_arch(init)
        if not os.path.isfile(bootloader):raise Exception("Bootloader %s does not exist when it's needed" % bootloader)
        return ["kernel='%s'" % bootloader]

    # pv-grub1
    if os.path.isfile(grub1_cfg):
        bootloader = "/usr/lib/xen/boot/pv-grub-x86_%d.gz" % detect_arch(init)
        if not os.path.isfile(bootloader):raise Exception("Bootloader %s does not exist when it's needed" % bootloader)
        return ["kernel='%s'" % bootloader, "extra='(hd0)/boot/grub/menu.lst'"]

    #else
    kernel = "/boot/vmlinuz.domU"
    if not os.path.isfile(kernel): raise Exception("DomU kernel %s does not exist when it's needed" % kernel)
    if not os.path.isfile(init): raise Exception("%s is missimg in VM" % kernel)
    return ["kernel='%s'" % kernel, "root='/dev/xvda1 ro'"]

def run(name, default_memory = 128, console = False):
    device, name = (name, os.path.basename(name)) if is_block(name) and make_sure_its_vm(name) else (get_device(name), name)
    make_sure_device_is_not_being_used(device)
    
    with create_install_disk.tempmount(device, "ro") as tempdir:
        configfile = os.path.join(tempdir, "etc/xen/config")
        config = []
        if os.path.isfile(configfile):
            with open(configfile) as f:
                config = f.read().splitlines()
        config += determine_boot_type(tempdir)

    config.append("name='%s'" % name)

    uuid = subprocess.check_output(["blkid","-s","UUID","-o", "value", device]).strip()
    if uuid == "": raise Exception("No UUID comes with device %s" % device)
    config.append("uuid='%s'" % uuid)

    if not any([re.match(r'^\s*memory\s*=',x) is not None for x in config]):
        config.append("memory=%d" % default_memory)

    if not any([re.match(r'^\s*disk\s*=',x) is not None for x in config]):
        config.append("disk=['phy:%s,xvda1,w']" % device)

    if not any([re.match(r'^\s*vif\s*=',x) is not None for x in config]):
        config.append("vif=['']")

    cmdline = ["xl", "create"]
    if console: cmdline.append("-c")
    cmdline += ["/dev/null", ';'.join(config)]
    #print cmdline
    subprocess.check_call(cmdline)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-c", action="store_true", help="Connect to console")
    parser.add_argument("--default-memory", type=int, default=128, help="Default memory capacity")
    parser.add_argument("name", type=str, help="VM name or device")
    args = parser.parse_args()
    try:
        run(args.name, args.default_memory, args.c)
    except subprocess.CalledProcessError, e:
        sys.exit(e.returncode)
