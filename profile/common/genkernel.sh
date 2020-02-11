#!/bin/sh
[ -f genkernel-options ] && GENKERNEL_OPTS=$(cat genkernel-options)
GENKERNEL_COMMAND=all
[ -f /initramfs.lst ] && GENKERNEL_COMMAND=kernel

rm -f /usr/src/linux/.config
[ -f /linuxrc ] && GENKERNEL_OPTS="$GENKERNEL_OPTS --linuxrc=/linuxrc"
[ -f /menuconfig ] && GENKERNEL_OPTS="$GENKERNEL_OPTS --menuconfig" && rm -f /menuconfig /var/cache/genkernel/kerncache.tar.gz
genkernel $GENKERNEL_OPTS --symlink --no-mountboot --no-bootloader \
  --kernel-config=/etc/kernels/kernel-config --makeopts="-j$((`nproc` + 1))" \
  --kernel-localversion=UNSET --no-save-config --no-module-rebuild --no-keymap \
  --compress-initramfs --compress-initramfs-type=xz \
  --kerncache=/var/cache/genkernel/kerncache.tar.gz ${GENKERNEL_COMMAND} || exit 1
if [ -f /usr/src/linux/.config ]; then
  truncate -s 0 -c /etc/kernels/kernel-config && cat /usr/src/linux/.config >> /etc/kernels/kernel-config
  tar zcf /var/cache/genkernel/kerncache-config.tar.gz -C /usr/src/linux .config include/config/auto.conf include/generated Module.symvers ./include/config ./arch/x86/include/generated ./scripts ./tools || exit 1
  touch modules_need_to_be_rebuilt
else
  tar xf /var/cache/genkernel/kerncache-config.tar.gz -C /usr/src/linux || exit 1
fi
