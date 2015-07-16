#!/bin/sh
KERNEL_NAME=`readlink /usr/src/linux | sed 's/linux-//'`
KERNEL_CONFIG=/etc/kernels/kernel-config-x86-$KERNEL_NAME
if [ ! -f "$KERNEL_CONFIG" ];then
	echo "Kernel config file '$KERNEL_CONFIG' doesn't exist."
	exit 1
fi
genkernel --no-mountboot --lvm --mdadm --symlink --splash=natural_gentoo all

