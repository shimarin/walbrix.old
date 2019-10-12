#!/usr/bin/python2.7
import subprocess,pwd,grp,glob,re,os,multiprocessing

def exec_cmd(cmdline):
    shell = isinstance(cmdline,str)
    subprocess.check_call(cmdline, shell=shell)
    #print cmdline

## add users/groups

def groupadd_if_not_exists(gid, name):
    try:
        if grp.getgrnam(name).gr_gid != gid:
            raise Exception("gid mismatch: %s" % name)
    except KeyError:
        exec_cmd(["groupadd","-g",str(gid),name])

def useradd_if_not_exists(uid, name, group, added_for,homedir, shell):
    try:
        pw = pwd.getpwnam(name)
        if pw.pw_uid != uid:
            raise Exception("uid mismatch: %s" % name)
    except KeyError:
        exec_cmd(["useradd","-c","added by portage for %s" % added_for, "-d",homedir,"-u",str(uid),"-g",group,"-s",shell,name])

groups = [
    (12, "mail"),
    (101, "messagebus"),
    (102, "avahi"),
    (103, "openvpn"),
    (104, "tcpdump"),
    (105, "zabbix"),
    (106, "snort"),
    (107, "dhcp"),
    (108, "nginx"),
    (109, "dnsmasq"),
    (125, "crontab"),
    (126, "netdev"),
    (127, "plugdev"),
    (128, "ssmtp")
]

users = [
    #(uid, name, group, added_for, homedir, shell)
    (14, "postmaster", "mail", "mailbase","/var/spool/mail","/sbin/nologin"),
    (103, "openvpn", "openvpn", "openvpn","/dev/null","/sbin/nologin"),
    (102, "avahi", "avahi", "avahi","/dev/null","/sbin/nologin"),
    (101, "messagebus", "messagebus", "dbus","/dev/null","/sbin/nologin"),
    (104, "tcpdump", "tcpdump", "tcpdump","/dev/null","/sbin/nologin"),
    (105, "zabbix", "zabbix", "zabbix","/var/lib/zabbix/home","/sbin/nologin"),
    (106, "snort", "snort", "snort","/dev/null","/sbin/nologin"),
    (107, "dhcp", "dhcp", "dhcp","/var/lib/dhcp","/sbin/nologin"),
    (108, "nginx", "nginx", "nginx", "/var/lib/nginx", "/sbin/nologin"),
    (109, "dnsmasq", "dnsmasq", "dnsmasq", "/dev/null", "/sbin/nologin"),
    (200, "gpsd", "uucp", "gpsd", "/dev/null", "/sbin/nologin")
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

        kernel_filename = ("/boot/kernel-genkernel-%s-%s" + source + "%s") % (arch, version, revision)
        if not os.path.isfile(kernel_filename):
            print "Kernel %s%s%s needs to be built" % (version, source, revision)
            kerneldir = "/usr/src/linux-%s%s%s" % (version, source, revision)
            exec_cmd(["genkernel","--no-mountboot","--kerneldir=%s" % kerneldir] + concurrency_opts + genkernel_opts)
            return True
    return False

exec_cmd(["emerge","-uDN","gentoo-sources","genkernel","splash-themes-gentoo"])
build_kernel_if_needed("gentoo", ["--lvm","--mdadm","--symlink","--splash=natural_gentoo","--no-compress-initramfs","all"])

kernel_build_time = os.path.getmtime(os.path.realpath("/boot/kernel"))
for pkg in ["sys-kernel/spl","sys-fs/zfs-kmod","x11-drivers/nvidia-drivers"]:
    build_times = [os.path.getmtime(f) for f in glob.glob("/var/db/pkg/%s-*/BUILD_TIME" % pkg)]
    if len(build_times) > 0 and max(build_times) < kernel_build_time: exec_cmd(["emerge","-1",pkg])

## emerge world

exec_cmd(["emerge","-uDN","--keep-going","world","@walbrix"])
exec_cmd(["emerge","@preserved-rebuild"])

## build sub kernels

#build_kernel_if_needed("aufs", ["bzImage"])
build_kernel_if_needed("", ["bzImage"])

