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

$SUDO tar Jcvpf ${ARTIFACT}.tar.xz -C build/${ARTIFACT} . || exit 1
echo "Done."
