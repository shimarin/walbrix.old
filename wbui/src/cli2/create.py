import argparse,os,sys,stat,subprocess,re,struct,errno,contextlib,shutil
import cli2.create_install_disk as util

ro_layer_re = re.compile(r'set WALBRIX_RO_LAYER=(.+)$',re.MULTILINE)
rw_layer_re = re.compile(r'set WALBRIX_RW_LAYER=(.+)$',re.MULTILINE)

def get_overlay_params(rootdir):
    grub_cfg = os.path.join(rootdir, "boot/grub/grub.cfg")
    if not os.path.isfile(grub_cfg): return None
    #else
    cfg = open(grub_cfg).read()
    ro_layer_match = ro_layer_re.search(cfg)
    rw_layer_match = rw_layer_re.search(cfg)
    if None in [ro_layer_match, rw_layer_match]: return None

    return (ro_layer_match.groups()[0], rw_layer_match.groups()[0])

@contextlib.contextmanager
def mount_vm(name, readonly=False,options=None):
    mount_options = []
    if readonly: mount_options.append("ro")
    if options is not None: mount_options.append(options)
    device, name = get_device_and_vmname(name)
    make_sure_device_is_not_being_used(device)
    with util.tempmount(device, ",".join(mount_options)) as tempdir:
        overlay_params = get_overlay_params(tempdir)
        if overlay_params is not None:
            ro_layer, rw_layer = overlay_params
            work_dir = os.path.join(tempdir, "work")
            if not readonly:
                if os.path.exists(work_dir): shutil.rmtree(work_dir)
                os.makedirs(work_dir)
            with util.tempmount(os.path.join(tempdir, ro_layer.strip('/')), "loop,ro", "squashfs") as ro_dir:
                rw_dir = os.path.join(tempdir, rw_layer.strip('/'))
                overlay_options = ["lowerdir=%s:%s" % (rw_dir, ro_dir)] if readonly else ["lowerdir=%s,upperdir=%s,workdir=%s" % (ro_dir, rw_dir, work_dir)]
                if readonly: overlay_options.append("ro")
                with util.tempmount("overlay", ",".join(overlay_options), "overlay") as overlay_root:
                    yield overlay_root
        else:
            yield tempdir

def is_block(name):
    try:
        return stat.S_ISBLK(os.stat(name)[stat.ST_MODE])
    except OSError, e:
        if e.errno != errno.ENOENT: raise
    return False

def is_vm(device):
    with util.tempmount(device, "ro") as tempdir:
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

def get_device(name, quiet=False):
    for line in subprocess.check_output(["lvs","--noheadings","--nosuffix","@wbvm","-o","lv_name,lv_path"], close_fds=True).splitlines():
        lv, device = map(lambda x:x.strip(), line.split())
        if lv == name and make_sure_its_vm(device):
            if not quiet: print "VM found: %s" % device
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

def determine_boot_type(vmroot):
    init = os.path.join(vmroot, "sbin/init")
    grub1_cfg = os.path.join(vmroot, "boot/grub/menu.lst")
    grub2_cfg = os.path.join(vmroot, "boot/grub/grub.cfg")
    grub1_bin = "/usr/lib/xen/boot/pv-grub-x86_64.gz"
    grub2_bin = "/usr/lib/xen/boot/pv-grub2-x86_64.gz" # https://github.com/wbrxcorp/walbrix/issues/61

    # pv-grub2 (considered 64bit)
    if os.path.isfile(grub2_bin) and os.path.isfile(grub2_cfg):
        return ["kernel='%s'" % grub2_bin]

    # pv-grub1 with 64bit VM
    if os.path.isfile(grub1_bin) and os.path.isfile(grub1_cfg):
        if not os.path.isfile(init) or detect_arch(init) == 64:
            return ["kernel='%s'" % grub1_bin, "extra='(hd0)/boot/grub/menu.lst'"]

    #else
    kernel = "/boot/kernel.domU"
    if not os.path.isfile(kernel): raise Exception("DomU kernel %s does not exist when it's needed" % kernel)
    if not os.path.isfile(init): raise Exception("/sbin/init is missimg in VM")
    return ["kernel='%s'" % kernel, "root='/dev/xvda1 ro'"]

def get_device_and_vmname(name, quiet=False):
    return (name, os.path.basename(name)) if is_block(name) and make_sure_its_vm(name) else (get_device(name, quiet), name)

def run(name, default_memory = 128, console = False, quiet=False):
    device, name = get_device_and_vmname(name, quiet)
    make_sure_device_is_not_being_used(device)

    with mount_vm(device, True) as tempdir:
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
    if quiet: cmdline.append("--quiet")
    cmdline += ["/dev/null", ';'.join(config)]
    subprocess.check_call(cmdline)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-c", action="store_true", help="Connect to console")
    parser.add_argument("--quiet", action="store_true", help="Quiet operation")
    parser.add_argument("--default-memory", type=int, default=128, help="Default memory capacity")
    parser.add_argument("name", type=str, help="VM name or device")
    args = parser.parse_args()
    try:
        run(args.name, args.default_memory, args.c, args.quiet)
    except subprocess.CalledProcessError, e:
        sys.exit(e.returncode)
