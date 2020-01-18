#!/bin/sh
if [ "$#" -lt 1 ] ; then
  echo "Usage: $0 artifact" 1>&2
  exit 1
fi

SUDO=
if [ "$EUID" -ne 0 ]; then
  SUDO=sudo
fi

ARTIFACT=$1

if [ ! -d build//${ARTIFACT} ]; then
  echo "build/${ARTIFACT} does not exist."
  exit 1
fi

$SUDO ./do.ts mksquashfs build/${ARTIFACT} ${ARTIFACT}.squashfs || exit 1
echo "Done."
