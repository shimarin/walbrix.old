import argparse,subprocess,shutil,os,contextlib,errno,time
import collect

def patient_umount(mountpoint):
    for i in range(10):
        if subprocess.call(["umount",mountpoint]) == 0: return
        # else
        print "Unmounting failed. waiting for something running in background to stop..."
        time.sleep(1)
    raise Exception("%s couldn't be unmounted despite retries." % mountpoint)

@contextlib.contextmanager
def bind_mount_if_both_exist(src, dst):
    exists = os.path.isdir(src) and os.path.isdir(dst)
    if exists: subprocess.check_call(["mount","-o","bind",src, dst])
    try:
        yield
    finally:
        try:
            os.wait()
        except OSError, e:
            if e.errno != errno.ECHILD: raise
        finally:
            if exists: patient_umount(dst)

def do_chroot(target_dir, command):
    if collect.is_executable("%s/sbin/ldconfig" % target_dir): subprocess.check_call(["chroot", target_dir, "/sbin/ldconfig"])
    with bind_mount_if_both_exist("/proc", "%s/proc" % target_dir):
        with bind_mount_if_both_exist("/dev", "%s/dev" % target_dir):
            with bind_mount_if_both_exist("/usr/portage", "%s/usr/portage" % target_dir):
                subprocess.check_call(["chroot", target_dir, "/bin/sh", "-c", command], env=collect.env_with_root_path())

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
                do_chroot(overlay_root, command)
            finally:
                subprocess.check_call(["umount", overlay_root])
        finally:
            shutil.rmtree(overlay_dir)
    else:
        do_chroot(context.destination, command)
