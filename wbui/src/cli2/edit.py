import argparse,subprocess,os,tempfile,contextlib,shutil,re
import cli2.create as create,cli2.create_install_disk as util

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
    device, name = create.get_device_and_vmname(name)
    create.make_sure_device_is_not_being_used(device)
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

def read_in_text(device):
    create.make_sure_device_is_not_being_used(device)

    with mount_vm(device, True) as tempdir:
        configfile = os.path.join(tempdir, "etc/xen/config")
        return open(configfile).read() if os.path.isfile(configfile) else ""

def read(device):
    vals = {}
    config = read_in_text(device)
    exec config in None, vals
    return vals

def write(device, vals):
    create.make_sure_device_is_not_being_used(device)

    with mount_vm(device, False) as tempdir:
        configfile = os.path.join(tempdir, "etc/xen/config")
        with open(configfile, "w") as f:
            for key, value in vals.iteritems():
                f.write("%s=%s\n" % (key, repr(value)))

def run(name):
    device, name = create.get_device_and_vmname(name)
    config = read_in_text(device)
    editor = os.environ.get("EDITOR") or "vi"
        
    with tempfile.NamedTemporaryFile(delete=True) as tmpfile:
        tmpfile.write(config)
        tmpfile.flush()
        subprocess.call([editor,tmpfile.name])
        tmpfile.seek(0)
        new_config = tmpfile.read()

    vals = {}
    exec new_config in None, vals

    if "memory" not in vals: raise Exception("memory= is mandatory")

    write(device, vals)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("name", type=str, help="VM name or device")
    args = parser.parse_args()
    run(args.name)
