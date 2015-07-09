import sys,contextlib,tempfile,os,subprocess,time

@contextlib.contextmanager
def apply(device, options = None, type = "auto"):
    tmpdir = tempfile.mkdtemp()
    try:
        cmdline = ["mount","-t",type]
        if options is not None: cmdline += ["-o",options]
        cmdline += [device,tmpdir]
        subprocess.check_call(cmdline)
        try:
            yield tmpdir
        finally:
            retry = 5
            while retry > 0:
                if subprocess.call(["umount",tmpdir]) == 0: break
                time.sleep(3)
                retry -= 1
    finally:
        os.rmdir(tmpdir)

if __name__ == '__main__':
    print "This module is not executable directly."
    sys.exit(1)
