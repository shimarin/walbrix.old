import argparse,subprocess,shutil,os,contextlib,time
import collect

def patient_unmount(path):
    for i in [1,2,3,4,5]:
        if subprocess.call(["umount",path]) == 0: return
        print "Unmounting %s failed. retrying..." % path
        time.sleep(3)
    raise Exception("Unmounting %s failed despite retrying.")

@contextlib.contextmanager
def proc_dev(root):
    proc = "%s/proc" % root
    dev = "%s/dev" % root
    mount_proc = os.path.isdir(proc)
    mount_dev = os.path.isdir(dev)

    if mount_proc: subprocess.check_call(["mount","-o","bind","/proc",proc])
    try:
        if mount_dev: subprocess.check_call(["mount","-o","bind","/dev",dev])
        try:
            yield
        finally:
            if mount_dev: patient_unmount(dev)
    finally:
        if mount_proc: patient_unmount(proc)

def apply(context, args):
    parser = argparse.ArgumentParser()
    parser.add_argument("--overlay", action="store_true", help="use overlay")
    parser.add_argument("command", type=str, help="command to execute inside chroot")
    args = parser.parse_args(args)
    command = context.apply_variables(args.command)
    print "$exec '%s'" % command
    if args.overlay:
        print "Using overlay"
        overlay_dir = os.path.normpath(context.destination) + ".overlay"
        overlay_root = overlay_dir + "/root"
        overlay_work = overlay_dir + "/work"
        collect.mkdir_p(overlay_root)
        collect.mkdir_p(overlay_work)
        try:
            overlayfs_opts = "lowerdir=%s,upperdir=%s,workdir=%s" % (context.source,context.destination,overlay_work)
            subprocess.check_call(["mount","-t","overlay","overlay","-o",overlayfs_opts,overlay_root])
            try:
                if collect.is_executable("%s/sbin/ldconfig" % overlay_root): subprocess.check_call(["chroot", overlay_root, "/sbin/ldconfig"])
                with proc_dev(overlay_root):
                    subprocess.check_call(["chroot", overlay_root, "/bin/sh", "-c", command], env=collect.env_with_root_path())
            finally:
                subprocess.check_call(["umount", overlay_root])
        finally:
            shutil.rmtree(overlay_dir)
    else:
        if collect.is_executable("%s/sbin/ldconfig" % context.destination): subprocess.check_call(["chroot", context.destination, "/sbin/ldconfig"])
        with proc_dev(context.destination):
            subprocess.check_call(["chroot", context.destination, "/bin/sh", "-c", command], env=collect.env_with_root_path())
