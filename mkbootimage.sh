#!/bin/sh
if [ "$#" -lt 1 ] ; then
  echo "Usage: $0 artifact" 1>&2
  exit 1
fi

ARTIFACT=$1

if [ ! -f ${ARTIFACT}.squashfs ]; then
  echo "${ARTIFACT}.squashfs does not exist. Run 'mksquashfs.sh ${ARTIFACT}' first."
  exit 1
fi

grub-mkimage -p /boot/grub -c resource/efi/grub.cfg -o bootx64.efi -O x86_64-efi xfs fat part_gpt part_msdos normal linux echo all_video test multiboot multiboot2 search sleep iso9660 gzio lvm chain configfile cpuid minicmd gfxterm font terminal squash4 loopback videoinfo videotest blocklist probe

IMAGE_SIZE=$(wc -c < bootx64.efi)
PAD_SIZE=$((1024*1024 - $IMAGE_SIZE))

truncate -s +$PAD_SIZE bootx64.efi
cat bootx64.efi ${ARTIFACT}.squashfs > ${ARTIFACT}.efi

echo "Done."
