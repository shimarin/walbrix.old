import argparse,os,subprocess,shutil,sys
import collect

def apply(context, args):
    parser = argparse.ArgumentParser()
    parser.add_argument("destfile", type=str, help="Destination file")
    parser.add_argument("--preserve-root", type=str, default="", help="Root directory for preserving files")
    parser.add_argument("--preserve", type=str, nargs='*', help="Root directory for preserving files")

    args = parser.parse_args(args)

    squashfs_tmp = context.destination + ".squashfs"
    os.rename(context.destination, squashfs_tmp)
    try:
        dirname = os.path.dirname(args.destfile).strip('/')
        basename = os.path.basename(args.destfile)
        os.makedirs(os.path.join(context.destination, dirname))

        for preserve in args.preserve:
            src = os.path.join(squashfs_tmp, preserve.strip('/'))
            dest = os.path.join(context.destination, args.preserve_root.strip('/'), preserve.strip('/'))
            if os.path.isdir(src):
                os.makedirs(dest)
                shutil.copymode(src, dest)
            else:
                destdir = os.path.dirname(dest)
                if not os.path.isdir(destdir): os.makedirs(destdir)
                shutil.copy(src, dest)
        
        destfile = os.path.join(context.destination, dirname, basename)
        subprocess.check_call(["mksquashfs",squashfs_tmp,destfile,"-noappend"])
    finally:
        shutil.rmtree(squashfs_tmp)

if __name__ == '__main__':
    os.mkdir("testdir")
    try:
        apply(collect.Context("", "testdir"), sys.argv[1:])
    finally:
        shutil.rmtree("testdir")
