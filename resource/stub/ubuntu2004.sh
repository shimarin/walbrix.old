#!/bin/sh
mkfs.xfs -f /dev/xvda2 || exit 1
mount /dev/xvda2 /mnt || exit 1

debootstrap --include="ubuntu-minimal,initramfs-tools,openssh-server,linux-generic,avahi-daemon,locales-all" focal /mnt http://ubuntutym.u-toyama.ac.jp/ubuntu

hostname > /mnt/etc/hostname
mkdir -p /mnt/boot/grub
echo -e 'linux /boot/vmlinuz root=/dev/xvda1 console=hvc0\ninitrd /boot/initrd.img\nboot' > /mnt/boot/grub/grub.cfg

sed -i 's/^\(root:\)[^:]*\(:.*\)$/\1\2/' /mnt/etc/shadow
echo -e '/dev/xvda1 /                       xfs     defaults        1 1' > /mnt/etc/fstab
echo -e 'network:\n  version: 2\n  renderer: networkd\n  ethernets:\n    eth0:\n      dhcp4: true\n      dhcp6: true' > /etc/netplan/99_config.yaml

umount /mnt


