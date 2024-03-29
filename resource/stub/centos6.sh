#!/bin/sh
mkfs.xfs -f -m crc=0 -n ftype=0 /dev/xvda2 || exit 1
mount /dev/xvda2 /mnt || exit 1
mkdir -p /mnt/etc/dracut.conf.d
echo 'add_drivers+="xen-blkfront"' > /mnt/etc/dracut.conf.d/xen.conf
rpmbootstrap --base=http://ftp.iij.ad.jp/pub/linux/centos-vault/6.10/os/`arch`/ /mnt || exit 1
echo -e 'DEVICE="eth0"\nBOOTPROTO=dhcp\nONBOOT=yes\nTYPE="Ethernet"' > /mnt/etc/sysconfig/network-scripts/ifcfg-eth0
echo -e 'search local\nnameserver 8.8.8.8\nnameserver 8.8.4.4' > /mnt/etc/resolv.conf
sed -i 's/^\(root:\)[^:]*\(:.*\)$/\1\2/' /mnt/etc/shadow
sed -i 's/^use-ipv6=no$/use-ipv6=yes/' /mnt/etc/avahi/avahi-daemon.conf
echo 'LANG=ja_JP.utf8' > /mnt/etc/locale.conf
cp -a /etc/localtime /mnt/etc/

echo -e '/dev/xvda1 /                       xfs     defaults        1 1' > /mnt/etc/fstab
echo -e "HOSTNAME=`hostname`\nNETWORKING=yes" > /mnt/etc/sysconfig/network
mkdir -p /mnt/boot/grub
echo -e 'linux /boot/vmlinuz root=/dev/xvda1\ninitrd /boot/initramfs\nboot' > /mnt/boot/grub/grub.cfg
pushd /mnt/boot
ln -s vmlinuz-* vmlinuz
ln -s initramfs-* initramfs
popd

chroot /mnt rpm --rebuilddb
chroot /mnt sed -i -e "s/^mirrorlist=http:\/\/mirrorlist.centos.org/#mirrorlist=http:\/\/mirrorlist.centos.org/g" /etc/yum.repos.d/CentOS-Base.repo
chroot /mnt sed -i -e "s/^#baseurl=http:\/\/mirror.centos.org/baseurl=http:\/\/vault.centos.org/g" /etc/yum.repos.d/CentOS-Base.repo
umount /mnt
