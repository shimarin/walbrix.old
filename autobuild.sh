#!/bin/sh
if [ "$#" -eq 0 ] ; then
  echo "Usage: $0 <profile>" 1>&2
  exit 1
fi

SUDO=
if [ "$EUID" -ne 0 ]; then
  SUDO=sudo
fi

PROFILE=$1
STAGE3_URL=`./do.ts determine-latest-stage3`
STAGE3_FILE=download_cache/`./do.ts download --hash $STAGE3_URL`
echo "Stage3 tarball is $STAGE3_URL ."
$SUDO ./do.ts download "$STAGE3_URL" || exit

GENTOO_DIR=gentoo/$PROFILE

$SUDO rm -rf "$GENTOO_DIR"
$SUDO mkdir -p $GENTOO_DIR
$SUDO tar xvpf $STAGE3_FILE -C $GENTOO_DIR
$SUDO mkdir -p $GENTOO_DIR/etc/kernels
$SUDO ln profile/$PROFILE/package.keywords $GENTOO_DIR/etc/portage/package.keywords
$SUDO ln profile/$PROFILE/package.license $GENTOO_DIR/etc/portage/package.license
$SUDO ln profile/$PROFILE/package.use $GENTOO_DIR/etc/portage/package.use/$PROFILE
if [ -f profile/$PROFILE/package.mask ]; then
	$SUDO ln profile/$PROFILE/package.mask $GENTOO_DIR/etc/portage/package.mask
fi

if [ -f profile/$PROFILE/package.provided ]; then
	$SUDO mkdir -p $GENTOO_DIR/etc/portage/profile
	$SUDO ln profile/$PROFILE/package.provided $GENTOO_DIR/etc/portage/profile/package.provided
fi

$SUDO mkdir -p $GENTOO_DIR/etc/portage/sets
$SUDO ln profile/$PROFILE/set $GENTOO_DIR/etc/portage/sets/all

if [ -f profile/$PROFILE/set-pre ]; then
	$SUDO ln profile/$PROFILE/set-pre $GENTOO_DIR/etc/portage/sets/all-pre
fi

$SUDO ln profile/$PROFILE/kernel-config $GENTOO_DIR/etc/kernels/kernel-config
$SUDO ln resource/walbrix/linuxrc $GENTOO_DIR/tmp/linuxrc

$SUDO cp -a profile/common/*.sh $GENTOO_DIR/

$SUDO ./do.ts chroot --profile=$PROFILE "$GENTOO_DIR" "/build.sh" || exit

rm -f profile/$PROFILE/rdepends
for i in $GENTOO_DIR/var/db/pkg/*/*/RDEPEND; do
	CATEGORY=$(cat `dirname $i`/CATEGORY)
	PF=$(cat `dirname $i`/PF | sed 's/-r[0-9]\+$//' | sed 's/-[^-]\+$//')
	RDEPEND=$(cat $i)
	echo -e "$CATEGORY/$PF\t$RDEPEND" >> profile/$PROFILE/rdepends
done
