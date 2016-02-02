#!/usr/bin/python2.7
import subprocess,pwd,grp,glob,re,os

def exec_cmd(cmdline):
    shell = isinstance(cmdline,str)
    subprocess.check_call(cmdline, shell)
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
    exec_cmd(["useradd","-c","added by portage for %s" % added_for, "-d",homedir,"-u",str(uid),"-g",group,"-s",shell,name])

groups = [
    (124, "postmaster"),
    (101, "openvpn"),
    (102, "avahi"),
    (103, "messagebus"),
    (104, "tcpdump"),
    (105, "zabbix"),
    (106, "snort"),
    (107, "dhcp"),
    (125, "crontab"),
    (126, "netdev"),
    (127, "plugdev"),
    (128, "ssmtp")
]

users = [
    #(uid, name, group, added_for, homedir, shell)
    (14, "postmaster", "postmaster", "mailbase","/var/spool/mail","/sbin/nologin"),
    (101, "openvpn", "openvpn", "openvpn","/dev/null","/sbin/nologin"),
    (102, "avahi", "avahi", "avahi","/dev/null","/sbin/nologin"),
    (103, "messagebus", "messagebus", "dbus","/dev/null","/sbin/nologin"),
    (104, "tcpdump", "tcpdump", "tcpdump","/dev/null","/sbin/nologin"),
    (105, "zabbix", "zabbix", "zabbix","/var/lib/zabbix/home","/sbin/nologin"),
    (106, "snort", "snort", "snort","/dev/null","/sbin/nologin"),
    (107, "dhcp", "dhcp", "dhcp","/var/lib/dhcp","/sbin/nologin")
]

for group in groups:
    groupadd_if_not_exists(group[0], group[1])

for user in users:
    useradd_if_not_exists(user[0], user[1], user[2], user[3], user[4],user[5])

## emerge/build main kernel

def build_kernel_if_needed(source = "gentoo", genkernel_opts=[]):
    source = "-" + source if source not in ["", None] else ""
    for kernel_config in glob.glob("/etc/kernels/kernel-config-*"):
        kernel_match = re.match(r'^kernel-config-(.[^-]+)-(.[^-]+)' + source + '(-r[0-9]+)?$', os.path.basename(kernel_config))
        if kernel_match is None: continue
        #else
        arch, version, revision = kernel_match.groups()
        if revision is None: revision = ""

        if not os.path.isfile(("/boot/kernel-genkernel-%s-%s" + source) % (arch, version)):
            print "Kernel %s%s%s needs to be built" % (version, source, revision)
            exec_cmd(["genkernel","--no-mountboot","--kerneldir=/usr/src/linux-%s%s%s" % (version, source, revision)] + genkernel_opts)
            return True
    return False

exec_cmd(["emerge","-uDN","gentoo-sources","genkernel","splash-themes-gentoo"])
if build_kernel_if_needed("gentoo", ["--lvm","--mdadm","--symlink","--splash=natural_gentoo","all"]):
    try:
        exec_cmd(["emerge","-1","zfs-kmod","spl"])
    except subprocess.CalledProcessError:
        print "Looks like ZFS modules are not compatible with this kernel."

## emerge world

exec_cmd(["emerge","-uDN","--keep-going","world","@walbrix"])
exec_cmd(["emerge","@preserved-rebuild"])

## build sub kernels

build_kernel_if_needed("aufs", ["bzImage"])
build_kernel_if_needed("", ["bzImage"])

