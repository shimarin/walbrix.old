import {f,pkg,exec,write} from "./collect.ts"

import "./python.ts"

pkg("dev-python/lxml")
pkg("app-emulation/xen-tools")
pkg("app-emulation/xen-pvgrub")
pkg("app-emulation/xen")
pkg("app-emulation/qemu")
pkg("sys-firmware/edk2-ovmf")
pkg("sys-firmware/ipxe")
pkg("sys-firmware/seabios")
pkg("sys-firmware/sgabios")
pkg("sys-apps/dtc")

f(
  "/var/lib/xen",
  "/var/log/xen"
)

//#$symlink /usr/lib/xen/boot ../../libexec/xen/boot
//#$sed /etc/init.d/xendomains 's/\(xl shutdown .*-w \)/\1-F /'
//#$sed /etc/init.d/xenconsoled 's/\(xl shutdown .*-w \)/\1-F /'

exec("systemctl enable xen-init-dom0")
exec("systemctl enable xen-watchdog")
exec("systemctl enable xenconsoled")
exec("systemctl enable xendomains")
exec("systemctl enable xenstored")

// pv(h)-grub2
write("/tmp/grub.cfg", 'set root=(xen/xvda1)\nnormal (xen/xvda1)/boot/grub/grub.cfg')
exec("grub-mkimage -c /tmp/grub.cfg -p /boot/grub -o /usr/libexec/xen/boot/pv-grub2-x86_64 -O x86_64-xen loopback xfs btrfs linux echo test gzio xzio probe configfile cpuid minicmd squash4 lsxen && gzip /usr/libexec/xen/boot/pv-grub2-x86_64")
exec("grub-mkimage -c /tmp/grub.cfg -p /boot/grub -o /usr/libexec/xen/boot/pvh-grub2-x86_64 -O i386-xen_pvh loopback xfs btrfs linux echo test gzio xzio probe configfile cpuid minicmd squash4 && gzip /usr/libexec/xen/boot/pvh-grub2-x86_64")

// some scripts need perl
f("/usr/bin/perl")
