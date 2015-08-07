import os,argparse,struct,subprocess,sys,contextlib,time

@contextlib.contextmanager
def yield_mounted(mountpoint):
    try:
        yield
    finally:
        for x in range(5):
         if subprocess.call(["umount",mountpoint]) == 0: return
         time.sleep(1)

@contextlib.contextmanager
def mount(type,device,mountpoint):
    subprocess.check_call(["mount","-t",type,device,mountpoint])
    with yield_mounted(mountpoint):
        yield

@contextlib.contextmanager
def bind_mount(source,mountpoint):
    subprocess.check_call(["mount","-o","bind",source,mountpoint])
    with yield_mounted(mountpoint):
        yield

def getExecutableBitWidth(filename):
    ei_class = None
    with open(filename, "rb") as f:
        if f.read(1) != b'\177' or f.read(3) != b"ELF": raise Exception
        ei_class = struct.unpack('B', f.read(1))[0]
    if ei_class == 1: return 32
    elif ei_class == 2: return 64
    #else
    raise Exception("Neither 32/64 bit")

def chroot(target, command):
    bw = getExecutableBitWidth("%s/bin/sh" % target)
    print("Chrooting %s" % target)
    if bw == 32:
        return subprocess.call(["i386","chroot",target] + command)
    else:
        return subprocess.call(["chroot",target] + command)

def run(target, command):
    if not os.path.isdir(target): raise Exception("Target directory '%s' doesn't exist" % target)
    if not os.path.isfile("%s/bin/sh" % target): raise Exception("/bin/sh not found under '%s'" % target)

    resolvconf = "%s/etc/resolv.conf" % target
    if not os.path.isfile(resolvconf):
        print("Creating /etc/resolv.conf...")
        with open(resolvconf, "w") as f:
            f.write("domain local\n")
            f.write("nameserver 8.8.8.8\n")
            f.write("nameserver 8.8.4.4\n")

    if os.path.isfile("%s/usr/bin/emerge" % target):
        portagedir = "%s/usr/portage" % target
        if not os.path.exists(portagedir):
            print("Creating /usr/portage")
            os.mkdir(portagedir)
    else:
    	print("(Doesn't look like Gentoo)")

    rst = None
    portage = "/usr/portage"

    with mount("proc","proc",os.path.join(target, "proc")):
        with bind_mount("/dev",os.path.join(target, "dev")):
            with mount("tmpfs","tmpfs",os.path.join(target, "dev/shm")):
                with bind_mount("/dev/pts", os.path.join(target, "dev/pts")):
                    if os.path.exists("%s/usr/portage/metadata/timestamp" % target) or not os.path.isdir("%s/usr/portage" % target) or portage == None:
                        rst = chroot(target, command)
                    else:
                        with bind_mount("/usr/portage", os.path.join(target, "usr/portage")):
                            rst = chroot(target, command)

    print("Cleanup chroot env")
    ## it harms /var/tmp/tomcat-*
    #os.system("rm -rf %s/var/tmp/*" % target)
    subprocess.call(["rm","-f","%s/var/log/emerge-fetch.log" % target])
    subprocess.call(["rm","-f","%s/root/.lesshst" % target])

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("dir", type=str, help="target dir")
    parser.add_argument("command", type=str, nargs=argparse.REMAINDER, default=["/bin/sh"], help="command to execute")
    args = parser.parse_args()

    if os.getuid() != 0: raise Exception("You must be a root user.")
    run(args.dir, args.command)
