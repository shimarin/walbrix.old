#!/bin/sh
if [ ! -d /var/db/pkg/app-emulation/xen-tools-* ]; then
	emerge -uDN1 -bk --binpkg-respect-use=y bin86 iasl dev-libs/glib pixman yajl pixman || exit 1
	USE="-api -hvm -ipxe -pam -pygrub -python -qemu-traditional -rombios -system-qemu" emerge -1 --nodeps xen-tools || exit 1
fi

