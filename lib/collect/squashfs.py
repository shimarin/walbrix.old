import argparse,os,subprocess,shutil
import collect

def apply(context, args):
    parser = argparse.ArgumentParser()
    parser.add_argument("destfile", type=str, help="Destination file")
    args = parser.parse_args(args)
    squashfs_tmp = context.destination + ".squashfs"
    os.rename(context.destination, squashfs_tmp)
    try:
        dirname = os.path.dirname(args.destfile).strip('/')
        basename = os.path.basename(args.destfile)
        os.makedirs(os.path.join(context.destination, dirname))
        destfile = os.path.join(context.destination, dirname, basename)
        subprocess.check_call(["mksquashfs",squashfs_tmp,destfile,"-noappend"])
    finally:
        shutil.rmtree(squashfs_tmp)
