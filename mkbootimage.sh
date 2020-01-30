#!/bin/sh
ARTIFACT=bootx64
BOOTLOADER=build/bootx64/bootx64.efi

if [ ! -f ${ARTIFACT}.squashfs ]; then
  echo "${ARTIFACT}.squashfs does not exist. Run 'mksquashfs.sh ${ARTIFACT}' first."
  exit 1
fi

if [ ! -f ${BOOTLOADER} ]; then
  echo "${BOOTLOADER} does not exist."
  exit 1
fi

cp $BOOTLOADER bootx64.efi
ORIGSIZE=$(wc -c < bootx64.efi)
PADSIZE=$((1024*1024 - $ORIGSIZE))
dd if=/dev/zero of=bootx64.efi seek=$ORIGSIZE bs=1 count=$PADSIZE
cat $ARTIFACT.squashfs >> bootx64.efi

echo "Done."
