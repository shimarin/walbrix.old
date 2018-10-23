#!/usr/bin/python2.7
import subprocess,pwd,grp,glob,re,os,multiprocessing

def exec_cmd(cmdline):
    shell = isinstance(cmdline,str)
    subprocess.check_call(cmdline, shell=shell)
    #print cmdline

## add users/groups

def groupadd_if_not_exists(gid, name):
    try:
        return grp.getgrnam(name)
    except KeyError:
        pass
    exec_cmd(["groupadd","-g",str(gid),name])

def useradd_if_not_exists(uid, name, group, added_for,homedir, shell):
    try:
        return pwd.getpwnam(name)
    except KeyError:
        pass
    exec_cmd(["useradd","-c","added by portage for %s" % added_for, "-d",homedir,"-M","-u",str(uid),"-g",group,"-s",shell,name])

groups = [
    (101, "openvpn"),
    (102, "avahi"),
    (103, "messagebus"),
    #(104, "tcpdump"),
    (105, "zabbix"),
    #(106, "lpadmin"),
    #(107, "dhcp"),
    (110, "nginx"),
    (111, "haproxy"),
    (112, "groonga"),
    (113, "clamav"),
    (124, "postmaster"),
    (125, "crontab"),
    (126, "netdev"),
    #(127, "plugdev"),
    #(128, "ssmtp"),
    (129, "docker"),
    (130, "jenkins"),
    (131, "mosquitto")
]

users = [
    #(uid, name, group, added_for, homedir, shell)
    (101, "openvpn", "openvpn", "openvpn","/dev/null","/sbin/nologin"),
    (102, "avahi", "avahi", "avahi","/dev/null","/sbin/nologin"),
    (103, "messagebus", "messagebus", "messagebus", "/dev/null", "/sbin/nologin"),
    (105, "zabbix", "zabbix", "zabbix","/var/lib/zabbix/home","/sbin/nologin"),
    (106, "postmaster", "postmaster", "postmaster", "/var/spool/mail", "/sbin/nologin"),
    (110, "nginx", "nginx", "nginx", "/var/lib/nginx", "/sbin/nologin"),
    (111, "haproxy", "haproxy", "haproxy", "/dev/null", "/sbin/nologin"),
    (112, "groonga", "groonga", "groonga", "/dev/null", "/sbin/nologin"),
    (113, "clamav", "clamav", "clamav", "/dev/null", "/sbin/nologin"),
    (114, "jenkins", "jenkins", "jenkins", "/var/lib/jenkins", "/sbin/nologin"),
    (115, "motion", "video", "motion", "/var/lib/motion", "/sbin/nologin"),
    (116, "mosquitto", "mosquitto", "mosquitto", "/dev/null", "/sbin/nologin")
]

for group in groups:
    groupadd_if_not_exists(group[0], group[1])

for user in users:
    useradd_if_not_exists(user[0], user[1], user[2], user[3], user[4],user[5])

## emerge/build main kernel

def build_kernel_if_needed(source = "gentoo", genkernel_opts=[]):
    cpu_count = multiprocessing.cpu_count()
    concurrency_opts = [ "--makeopts=\"-j%d\"" % (cpu_count + 1) ] if cpu_count > 1 else []
    source = "-" + source if source not in ["", None] else ""
    for kernel_config in glob.glob("/etc/kernels/kernel-config-*"):
        kernel_match = re.match(r'^kernel-config-(.[^-]+)-(.[^-]+)' + source + '(-r[0-9]+)?$', os.path.basename(kernel_config))
        if kernel_match is None: continue
        #else
        arch, version, revision = kernel_match.groups()
        if revision is None: revision = ""

        if not os.path.isfile(("/boot/kernel-genkernel-%s-%s" + source + "%s") % (arch, version, revision)):
            print "Kernel %s%s%s needs to be built" % (version, source, revision)
            kerneldir = "/usr/src/linux-%s%s%s" % (version, source, revision)
            if source == "-aufs":
                print "Applying AUFS on overlayfs patch..."
                if subprocess.call(["grep","-q","overlay","%s/fs/aufs/branch.c" % kerneldir],shell=False) != 0:
                    exec_cmd("wget -O - https://gist.githubusercontent.com/shimarin/d9bb3727edbb36f32eb315739e35cbfe/raw/b952a9c905b1ce9182ca602e493c5d9bae8c64e9/allow-aufs-to-work-on-overlayfs.patch | patch %s/fs/aufs/branch.c -p1" % kerneldir)
                else:
                    print "Patch has already been applied."
            exec_cmd(["genkernel","--no-mountboot","--kerneldir=%s" % kerneldir] + concurrency_opts + genkernel_opts)
            return True
    return False

exec_cmd(["emerge","-uDN","system","gentoo-sources","genkernel","lzop"])
if build_kernel_if_needed("gentoo", ["--no-compress-initramfs","--no-ramdisk-modules","--symlink","all"]):
    try:
        exec_cmd(["emerge","-1","--keep-going","nvidia-drivers"])
    except subprocess.CalledProcessError:
        print "Looks like NVIDIA modules are not compatible with this kernel."

## emerge world

exec_cmd(["emerge","-uDN","--keep-going","world","@walbrix"])
exec_cmd(["emerge","@preserved-rebuild"])

## build sub kernels

build_kernel_if_needed("", ["bzImage"])
#build_kernel_if_needed("aufs", ["bzImage"])

