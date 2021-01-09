#!/bin/sh
mkfs.xfs -f -m crc=0 /dev/xvda2 || exit 1
mount /dev/xvda2 /mnt || exit 1
mkdir -p /mnt/etc/dracut.conf.d
echo 'add_drivers+="xen-blkfront"' > /mnt/etc/dracut.conf.d/xen.conf
rpmbootstrap --base=http://ftp.iij.ad.jp/pub/linux/centos/7/os/x86_64/ /mnt
echo -e 'DEVICE="eth0"\nBOOTPROTO=dhcp\nONBOOT=yes\nTYPE="Ethernet"' > /mnt/etc/sysconfig/network-scripts/ifcfg-eth0
echo -e 'search local\nnameserver 8.8.8.8\nnameserver 8.8.4.4' > /mnt/etc/resolv.conf
sed -i 's/^\(root:\)[^:]*\(:.*\)$/\1\2/' /mnt/etc/shadow
sed -i 's/^use-ipv6=no$/use-ipv6=yes/' /mnt/etc/avahi/avahi-daemon.conf
echo 'LANG=ja_JP.utf8' > /mnt/etc/locale.conf
cp -a /etc/localtime /mnt/etc/

echo -e '/dev/xvda1 /                       xfs     defaults        1 1' > /mnt/etc/fstab
hostname > /mnt/etc/hostname
touch /mnt/etc/sysconfig/network
mkdir -p /mnt/boot/grub
echo -e 'linux /boot/vmlinuz root=/dev/xvda1\ninitrd /boot/initramfs\nboot' > /mnt/boot/grub/grub.cfg
pushd /mnt/boot
ln -s vmlinuz-* vmlinuz
ln -s initramfs-* initramfs
popd
chroot /mnt systemctl enable sshd avahi-daemon
umount /mnt
