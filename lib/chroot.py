import os,argparse,struct,subprocess
import tempmount

def getExecutableBitWidth(filename):
    ei_class = None
    with open(filename, "rb") as f:
        if f.read(1) != b'\177' or f.read(3) != b"ELF": raise Exception
        ei_class = struct.unpack('B', f.read(1))[0]
    if ei_class == 1: return 32
    elif ei_class == 2: return 64
    #else
    raise Exception("Neither 32/64 bit")

def chroot(target):
    bw = getExecutableBitWidth("%s/bin/sh" % target)
    print("Chrooting %s" % target)
    if bw == 32:
        return subprocess.call(["i386","chroot",target])
    else:
        return subprocess.call(["chroot",target])

def run(target):
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

    with tempmount.do("/proc", "%s/proc" % (target), "bind"):
        with tempmount.do("/dev", "%s/dev" % (target), "bind"):
            with tempmount.do("tmpfs", "%s/dev/shm" % (target)):
                with tempmount.do("/dev/pts", "%s/dev/pts" % (target), "bind"):
                    if os.path.exists("%s/usr/portage/metadata/timestamp" % target) or not os.path.isdir("%s/usr/portage" % target) or portage == None:
                        rst = chroot(target)
                    else:
                        with tempmount.do(portage, "%s/usr/portage" % (target), "bind"):
                            rst = chroot(target)

    print("Cleanup chroot env")
    ## it harms /var/tmp/tomcat-*
    #os.system("rm -rf %s/var/tmp/*" % target)
    subprocess.call(["rm","-f","%s/var/log/emerge-fetch.log" % target])
    subprocess.call(["rm","-f","%s/root/.lesshst" % target])

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("dir", type=str, help="target dir")
    args = parser.parse_args()

    if os.getuid() != 0: raise Exception("You must be a root user.")
    run(args.dir)
