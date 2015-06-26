from __future__ import print_function
import os

import system

def setupOptions(parser):
    parser.add_option("-p", "--portage", dest="portage", help="Specify portage directory to use in chroot env", default=None)

def chroot(target):
    s = system.getSystem()
    bw = s.getExecutableBitWidth("%s/bin/sh" % target)
    print("Chrooting %s" % target)
    if bw == 32:
        return os.system("i386 chroot %s" % (target))
    else:
        return os.system("chroot %s" % (target))

def run(options, args):
    if os.getuid() != 0: raise Exception("You must be a root user.")

    s = system.getSystem()
    target = s.getArchitectureString() if len(args) < 1 else args[0]

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
    portage = options.portage
    if portage == None:
        if os.path.isdir("./portage"): portage = "./portage"
        elif os.path.isdir("/usr/portage"): portage = "/usr/portage"

    with s.temporaryMount("/proc", "%s/proc" % (target), "bind"):
        with s.temporaryMount("/dev", "%s/dev" % (target), "bind"):
            with s.temporaryMount("tmpfs", "%s/dev/shm" % (target)):
                with s.temporaryMount("/dev/pts", "%s/dev/pts" % (target), "bind"):
                    if os.path.exists("%s/usr/portage/metadata/timestamp" % target) or not os.path.isdir("%s/usr/portage" % target) or portage == None:
                        rst = chroot(target)
                    else:
                        with s.temporaryMount(portage, "%s/usr/portage" % (target), "bind"):
                            rst = chroot(target)

    print("Cleanup chroot env")
    ## it harms /var/tmp/tomcat-*
    #os.system("rm -rf %s/var/tmp/*" % target)
    os.system("rm -f %s/var/log/emerge-fetch.log" % target)
    os.system("rm -f %s/root/.lesshst" % target)
    return rst
