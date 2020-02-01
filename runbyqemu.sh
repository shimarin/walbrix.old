#!/bin/sh
SUDO=
if [ "$EUID" -ne 0 ]; then
  SUDO=sudo
fi

SYSTEM_IMAGE=$1
DISK_IMAGE=cache/qemu-hda.img
SECONDARY_DISK_IMAGE=cache/qemu-hdb.img
mkdir -p cache

if [ ! -f "$DISK_IMAGE" ]; then
	echo -n "Creating primary disk image file..."
	truncate -s 4096M $DISK_IMAGE
	echo "done."
fi

echo -n "Creating secondary disk image file..."
truncate -s 4096M $SECONDARY_DISK_IMAGE
echo "done."

LOOP=$(losetup -P -f --show $DISK_IMAGE)

if [ -z "$LOOP" -o ! -b "$LOOP" ]; then
	echo "Failed to setup loopback device."
	exit 1
fi

BOOT_PARTITION=${LOOP}p1
BOOT_PARTITION_FSTYPE=$(blkid $BOOT_PARTITION | sed 's/.*TYPE="\([^"]\+\).*/\1/')
STATUS=0

if [ "$BOOT_PARTITION_FSTYPE" != "vfat" ]; then
	echo -n "Creating partitions..."
	$SUDO parted --script "$LOOP" "mklabel msdos"
	$SUDO parted --script "$LOOP" "mkpart primary 1MiB -1"
	$SUDO parted --script "$LOOP" "set 1 boot on"
	$SUDO parted --script "$LOOP" "set 1 esp on"
	$SUDO mkfs.vfat -F 32 $BOOT_PARTITION
	echo "done."
fi

TMPDIR=runbyqemu-boot-$$
mkdir $TMPDIR
if sudo mount ${LOOP}p1 $TMPDIR; then
	if [ ! -f $TMPDIR/boot/grub/grub.cfg ]; then
		echo -n "Installing bootloader..."
		$SUDO mkdir -p ${TMPDIR}/boot/grub
		DEVICEMAP=runbyqemu-devicemap-$$
		echo -e "(hd0) $LOOP\n" > $DEVICEMAP
		$SUDO cp $DEVICEMAP $TMPDIR/boot/grub/device.map
		rm -f $DEVICEMAP
		if $SUDO grub-install --target=i386-pc --boot-directory=${TMPDIR}/boot --modules="normal echo linux probe sleep test ls cat configfile" $LOOP; then
			$SUDO rm -f $TMPDIR/boot/grub/device.map
			GRUBCFG=runbyqemu-grubcfg-$$
			echo -e 'insmod echo\ninsmod linux\nset BOOT_PARTITION=$root\nloopback --offset1m loop /efi/boot/bootx64.efi\nset root=loop\nset prefix=($root)/boot/grub\nnormal' > $GRUBCFG
			$SUDO cp $GRUBCFG ${TMPDIR}/boot/grub/grub.cfg
			rm -f $GRUBCFG
			echo "done."
		else
			echo "failed."
		fi
	fi

	echo -n "Copying EFI bootloader..."
	$SUDO mkdir -p ${TMPDIR}/efi/boot
	$SUDO cp bootx64.efi ${TMPDIR}/efi/boot/
	echo "done."

	if [ -n "$SYSTEM_IMAGE" ]; then
		echo -n "Copying system image..."
		$SUDO cp "$SYSTEM_IMAGE" ${TMPDIR}/system.img
		echo "done."
	fi

	if [ -f firmware.tgz ]; then
		echo -n "Copying firmware archive..."
		$SUDO cp firmware.tgz ${TMPDIR}/efi/boot/
		echo "done."
	fi

	echo -n "Unmounting boot partition..."
	$SUDO umount $TMPDIR
	rmdir $TMPDIR
	echo "done."
else
	echo "Failed to mount boot partition."
	STATUS=1
fi

losetup -d $LOOP
[ "$STATUS" -ne 0 ] && exit $STATUS

qemu-system-x86_64 -enable-kvm -drive file=$DISK_IMAGE,format=raw,index=0,media=disk -drive file=$SECONDARY_DISK_IMAGE,format=raw,index=1,media=disk -rtc base=utc,clock=rt -m 4096 -vga cirrus -no-shutdown
