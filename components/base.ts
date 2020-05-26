import {f,kernel,pkg,exec} from "./collect.ts";

kernel("/boot/kernel");
f("/boot/initramfs");

exec("find /lib/modules/$KERNEL_VERSION -exec touch -ach {} \\;")
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
await import("./psmisc.ts");

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
  "/var/tmp",
  "/root",
  "/var/run",
  "/mnt"
);

// /tmp, /sys /dev /proc /run

await import("./glibc-minimal.ts");

exec("find /dev -exec touch -ach {} \\;");

exec("echo -e 'overlay\t/\toverlay\tdefaults\t0 0\n' > /etc/fstab");
exec("sed -i 's/^root:\*:/root::/' /etc/shadow"); // Empty root password

exec("rm -rf /var/lock && ln -sf /run/lock /var/lock");
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

await import("./cron.ts");
pkg("net-misc/openssh");
exec(`sed -i 's/^#PermitRootLogin prohibit-password$/PermitRootLogin yes/' /etc/ssh/sshd_config
mkdir -p /root/.ssh && chmod 700 /root/.ssh
touch /root/.ssh/authorized_keys
systemctl enable sshd`);

exec("echo -e '[Match]\nName=eth0\n[Network]\nDHCP=yes\nMulticastDNS=yes\nLLMNR=yes' > /etc/systemd/network/50-eth0.network")
exec("mkdir -p /etc/systemd/dnssd")
exec("systemctl enable systemd-networkd");
exec("systemctl enable systemd-resolved");

exec("echo -e '[Unit]\nDescription=/etc/rc.local Compatibility\nConditionPathExists=/etc/rc.local\n\n[Service]\nType=forking\nExecStart=/etc/rc.local start\nTimeoutSec=0\nStandardOutput=tty\nRemainAfterExit=yes\nSysVStartPriority=99\n\n[Install]\nWantedBy=multi-user.target' > /etc/systemd/system/rc-local.service")
//write("/etc/rc.local",  "#!/bin/sh\nexit 0");
//$exec "chmod +x /etc/rc.local"

exec("sed -i 's/ --prompt.*$//' /lib/systemd/system/systemd-firstboot.service")
