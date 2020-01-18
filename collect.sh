#!/bin/sh
if [ "$#" -lt 2 ] ; then
  echo "Usage: $0 artifact profile" 1>&2
  exit 1
fi

SUDO=
if [ "$EUID" -ne 0 ]; then
  SUDO=sudo
fi

ARTIFACT=$1
PROFILE=$2

if [ ! -f components/${ARTIFACT}.lst ]; then
  echo "components/${ARTIFACT}.lst does not exist."
  exit 1
fi

if [ ! -f gentoo/${PROFILE}/done ]; then
  echo "profile ${PROFILE} is not built yet. execute autobuild.sh ${PROFILE} first."
  exit 1
fi

echo "Cleanup build/${ARTIFACT}..."
$SUDO rm -rf build/${ARTIFACT}
$SUDO ./do.ts collect gentoo/${PROFILE} build/${ARTIFACT} components/${ARTIFACT}.lst || exit 1
echo "Done."

