import argparse,subprocess,shutil,os,contextlib
import collect

@contextlib.contextmanager
def proc_dev(root):
    subprocess.check_call(["mount","-o","bind","/proc","%s/proc" % root])
    try:
        subprocess.check_call(["mount","-o","bind","/dev","%s/dev" % root])
        try:
            yield
        finally:
            subprocess.check_call(["umount","%s/dev" % root])
    finally:
        subprocess.check_call(["umount","%s/proc" % root])

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
