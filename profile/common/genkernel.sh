#!/bin/sh
genkernel --lvm --mdadm --symlink --no-mountboot --no-bootloader --no-compress-initramfs \
  --kernel-config=/etc/kernels/kernel-config --makeopts="-j$((`nproc` + 1))" \
  --linuxrc=/tmp/linuxrc --kernel-localversion=UNSET \
  --no-save-config \
  --kerncache=/var/cache/genkernel/kerncache.tar.gz all || exit 1
if [ -f /usr/src/linux/.config ]; then
  truncate -s 0 -c /etc/kernels/kernel-config && cat /usr/src/linux/.config >> /etc/kernels/kernel-config
  tar zcf /var/cache/genkernel/kerncache-config.tar.gz -C /usr/src/linux .config include/config/auto.conf include/generated Module.symvers ./include/config ./arch/x86/include/generated ./scripts ./tools || exit 1
else
  tar xf /var/cache/genkernel/kerncache-config.tar.gz -C /usr/src/linux || exit 1
fi

