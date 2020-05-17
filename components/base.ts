import {f,kernel,dir,pkg,write,sed,symlink,mkdir,touch,exec,env} from "./collect.ts";

kernel("/boot/kernel");
await f(
  "/boot/kernel",
  "/boot/initramfs",
  "/lib/modules"
);
dir(`/lib/modules/${env["KERNEL_VERSION"]}`);
pkg("sys-apps/kmod");

await import("./baselayout.ts");

pkg("coreutils");
pkg("grep");
pkg("procps");
pkg("findutils");
pkg("timezone-data");
pkg("sys-apps/attr");

pkg("net-tools");
pkg("sys-apps/iproute2");

await import("./bash-minimal.ts");
await import("./pam.ts");
import("./psmisc.ts");

pkg("iputils");
pkg("sys-apps/less");

// sys-apps/file
f(
  "/usr/bin/file",
  "/usr/share/misc/magic.mgc"
);

f(
  "/usr/bin/ldd",
  "/usr/bin/nano",
  "/usr/bin/vi",
  "/bin/sed",
  "/bin/awk",
  "/bin/tar",
  "/bin/gzip",
  "/bin/gunzip",
  "/bin/bzip2",
  "/bin/bunzip2",
  "/usr/bin/xz",
  "/usr/bin/unxz",
  "/usr/bin/unzip",
  "/usr/bin/wget",
  "/usr/bin/curl",
  "/usr/bin/rsync",
  "/usr/bin/strace",
  "/usr/sbin/tcpdump",
  "/usr/bin/telnet"
);

pkg("dev-libs/openssl");
pkg("app-misc/ca-certificates");

f(
  "/home",
  "/tmp",
  "/var/tmp",
  "/root",
  "/sys",
  "/proc",
  "/run",
  "/var/run",
  "/mnt"
);

await import("./glibc-minimal.ts");

dir("/dev");

write("/etc/fstab", "overlay\t/\toverlay\tdefaults\t0 0\n");
sed("/etc/shadow", `s/^root:\*:/root::/`); // Empty root password

symlink("/var/lock", "/run/lock");
pkg("sys-apps/systemd");
pkg("sys-apps/gentoo-systemd-integration");
pkg("sys-apps/util-linux");
pkg("sys-apps/dbus");
pkg("sys-libs/libcap");
pkg("sys-apps/acl");
//dev-libs/libgcrypt
pkg("app-arch/lz4");
pkg("sys-libs/pam");
//dev-libs/libpcre2
//sys-libs/libseccomp
pkg("sys-apps/kmod");
pkg("net-vpn/wireguard-tools");

import("./cron.ts");
pkg("net-misc/openssh");
sed("/etc/ssh/sshd_config", `s/^#PermitRootLogin prohibit-password$/PermitRootLogin yes/`);
mkdir("/root/.ssh", {mode:0o700});
touch("/root/.ssh/authorized_keys");
exec("systemctl enable sshd");

write("/etc/systemd/network/50-eth0.network", "[Match]\nName=eth0\n[Network]\nDHCP=yes\nMulticastDNS=yes\nLLMNR=yes");
mkdir("/etc/systemd/dnssd");
exec("systemctl enable systemd-networkd");
exec("systemctl enable systemd-resolved");

write("/etc/systemd/system/rc-local.service", "[Unit]\nDescription=/etc/rc.local Compatibility\nConditionPathExists=/etc/rc.local\n\n[Service]\nType=forking\nExecStart=/etc/rc.local start\nTimeoutSec=0\nStandardOutput=tty\nRemainAfterExit=yes\nSysVStartPriority=99\n\n[Install]\nWantedBy=multi-user.target");
//write("/etc/rc.local",  "#!/bin/sh\nexit 0");
//$exec "chmod +x /etc/rc.local"

sed("/lib/systemd/system/systemd-firstboot.service", `s/ --prompt.*$//`);
