#!/bin/sh
mkfs.xfs -f -m crc=0 /dev/xvda2 || exit 1
mount /dev/xvda2 /mnt || exit 1

debootstrap --arch amd64 jessie --include="openssh-server,avahi-daemon,ntp,ca-certificates,locales-all,linux-image-amd64" /mnt

hostname > /mnt/etc/hostname
mkdir -p /mnt/boot/grub
echo -e 'linux /vmlinuz root=/dev/xvda1\ninitrd /initrd.img\nboot' > /mnt/boot/grub/grub.cfg

sed -i 's/^\(root:\)[^:]*\(:.*\)$/\1\2/' /mnt/etc/shadow
echo -e '/dev/xvda1 /                       xfs     defaults        1 1' > /mnt/etc/fstab

umount /mnt


