#!/bin/sh
[ -x /sbin/lvm ] && GENKERNEL_OPTS="$GENKERNEL_OPTS --lvm"
[ -x /sbin/mdadm ] && GENKERNEL_OPTS="$GENKERNEL_OPTS --mdadm"

rm -f /usr/src/linux/.config
[ -f /linuxrc ] && LINUXRC=--linuxrc=/linuxrc
[ -f /menuconfig ] && MENUCONFIG=--menuconfig && rm -f /menuconfig /var/cache/genkernel/kerncache.tar.gz
genkernel $GENKERNEL_OPTS --symlink --no-mountboot --no-bootloader --no-compress-initramfs \
  --kernel-config=/etc/kernels/kernel-config --makeopts="-j$((`nproc` + 1))" \
  $LINUXRC --kernel-localversion=UNSET \
  --no-save-config \
  --kerncache=/var/cache/genkernel/kerncache.tar.gz $MENUCONFIG all || exit 1
if [ -f /usr/src/linux/.config ]; then
  truncate -s 0 -c /etc/kernels/kernel-config && cat /usr/src/linux/.config >> /etc/kernels/kernel-config
  tar zcf /var/cache/genkernel/kerncache-config.tar.gz -C /usr/src/linux .config include/config/auto.conf include/generated Module.symvers ./include/config ./arch/x86/include/generated ./scripts ./tools || exit 1
  touch modules_need_to_be_rebuilt
else
  tar xf /var/cache/genkernel/kerncache-config.tar.gz -C /usr/src/linux || exit 1
fi
