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
GENTOO_DIR=gentoo/$PROFILE

if [ -z "$SKIP_INIT" ]; then

  if [ ! -x profile/$PROFILE/stage3-url.sh ]; then
    echo "Need profile/$PROFILE/stage3-url.sh which shows stage3 url to build gentoo corresponds to the profile."
    exit 1
  fi

  STAGE3_URL=$(sh profile/$PROFILE/stage3-url.sh)
  if [ -z "$STAGE3_URL" ]; then
  	echo "Stage3 URL could not be determined."
  	exit 1
  fi
  echo "Stage3 tarball is $STAGE3_URL ."
  STAGE3_HASH=$(echo -n "$STAGE3_URL"|md5sum|cut -f 1 -d " ")
  STAGE3_FILE=cache/download/$STAGE3_HASH

  if [ ! -f "$STAGE3_FILE" ]; then
  	TEMPFILE=cache/download/download-$$.tmp
  	mkdir -p cache/download
  	if wget -O $TEMPFILE $STAGE3_URL; then
  		mv $TEMPFILE $STAGE3_FILE
  	else
  		exit 1
  	fi
  fi

  [ -f "${GENTOO_DIR}/done" ] && DONE=$(cat "${GENTOO_DIR}/done")

  if [ "$DONE" != "$STAGE3_HASH" ]; then
    echo "Initializing $GENTOO_DIR ..."
    $SUDO rm -rf "$GENTOO_DIR"
    $SUDO mkdir -p $GENTOO_DIR
    echo "Extracting stage3..."
    $SUDO tar xpf $STAGE3_FILE -C $GENTOO_DIR || exit 1
    $SUDO mkdir -p $GENTOO_DIR/var/db/repos/gentoo || exit 1
    $SUDO sh -c "echo 'GENTOO_MIRRORS=\"http://ftp.iij.ad.jp/pub/linux/gentoo/\"' >> $GENTOO_DIR/etc/portage/make.conf"
    $SUDO sh -c "echo 'FEATURES=\"-sandbox -usersandbox -network-sandbox\"' >> $GENTOO_DIR/etc/portage/make.conf"
  fi

fi # SKIP_INIT

$SUDO cp /etc/resolv.conf $GENTOO_DIR/etc/resolv.conf
#$SUDO sh -c "echo -e 'nameserver 8.8.8.8\nnameserver 8.8.4.4' > $GENTOO_DIR/etc/resolv.conf"

if [ -f profile/$PROFILE/kernel-config ]; then
	$SUDO mkdir -p $GENTOO_DIR/etc/kernels
	$SUDO ln -f profile/$PROFILE/kernel-config $GENTOO_DIR/etc/kernels/kernel-config
fi

if [ -f profile/$PROFILE/genkernel-options ]; then
  $SUDO ln -f profile/$PROFILE/genkernel-options $GENTOO_DIR/
fi

[ -f profile/$PROFILE/package.keywords ] && $SUDO ln -f profile/$PROFILE/package.keywords $GENTOO_DIR/etc/portage/package.accept_keywords
[ -f profile/$PROFILE/package.accept_keywords ] && $SUDO ln -f profile/$PROFILE/package.accept_keywords $GENTOO_DIR/etc/portage/package.accept_keywords
[ -f profile/$PROFILE/package.license ] && $SUDO ln -f profile/$PROFILE/package.license $GENTOO_DIR/etc/portage/package.license
[ -f profile/$PROFILE/package.use ] && $SUDO ln -f profile/$PROFILE/package.use $GENTOO_DIR/etc/portage/package.use/$PROFILE
[ -f profile/$PROFILE/package.mask ] && $SUDO ln -f profile/$PROFILE/package.mask $GENTOO_DIR/etc/portage/package.mask

if [ -d profile/common/patches ]; then
  $SUDO mkdir -p $GENTOO_DIR/etc/portage/patches
  $SUDO cp -a profile/common/patches/. $GENTOO_DIR/etc/portage/patches/
fi

if [ -d profile/$PROFILE/patches ]; then
  $SUDO mkdir -p $GENTOO_DIR/etc/portage/patches
  $SUDO cp -a profile/$PROFILE/patches/. $GENTOO_DIR/etc/portage/patches/
fi

if [ -d profile/common/repos ]; then
  $SUDO mkdir -p $GENTOO_DIR/var/db/repos/localrepo
  $SUDO cp -a profile/common/repos/. $GENTOO_DIR/var/db/repos/localrepo/
fi

if [ -d profile/$PROFILE/repos ]; then
  $SUDO mkdir -p $GENTOO_DIR/var/db/repos/localrepo
  $SUDO cp -a profile/$PROFILE/repos/. $GENTOO_DIR/var/db/repos/localrepo/
fi

if [ -f profile/$PROFILE/package.provided ]; then
	$SUDO mkdir -p $GENTOO_DIR/etc/portage/profile
	$SUDO ln -f profile/$PROFILE/package.provided $GENTOO_DIR/etc/portage/profile/package.provided
fi

$SUDO mkdir -p $GENTOO_DIR/etc/portage/sets
[ -f profile/$PROFILE/set ] && $SUDO ln -f profile/$PROFILE/set $GENTOO_DIR/etc/portage/sets/all
[ -f profile/$PROFILE/set-pre ] && $SUDO ln -f profile/$PROFILE/set-pre $GENTOO_DIR/etc/portage/sets/all-pre
[ -f profile/$PROFILE/set-kernel ] && $SUDO ln -f profile/$PROFILE/set-kernel $GENTOO_DIR/etc/portage/sets/kernel

$SUDO ln -f profile/common/portage-bashrc $GENTOO_DIR/etc/portage/bashrc

#[ -f profile/$PROFILE/linuxrc ] && $SUDO ln -f profile/$PROFILE/linuxrc $GENTOO_DIR/linuxrc
$SUDO ln -f profile/common/init.h $GENTOO_DIR/init.h
$SUDO ln -f profile/common/initlib.h $GENTOO_DIR/initlib.h
if [ -f profile/$PROFILE/init.cpp ]; then
  $SUDO ln -f profile/common/initlib.cpp $GENTOO_DIR/initlib.cpp
  $SUDO ln -f profile/$PROFILE/init.cpp $GENTOO_DIR/init.cpp
elif [ -f profile/$PROFILE/init.c ]; then
  $SUDO ln -f profile/$PROFILE/init.c $GENTOO_DIR/init.c
fi
[ -f profile/$PROFILE/initramfs.lst ] && $SUDO ln -f profile/$PROFILE/initramfs.lst $GENTOO_DIR/initramfs.lst
[ -f profile/$PROFILE/initramfs.gen ] && $SUDO ln -f profile/$PROFILE/initramfs.gen $GENTOO_DIR/initramfs.gen

touch profile/$PROFILE/rdepends
$SUDO ln -f profile/$PROFILE/rdepends $GENTOO_DIR/rdepends
$SUDO ln -f profile/common/*.sh $GENTOO_DIR/

[ -f profile/$PROFILE/before-emerge.sh ] && $SUDO ln -f profile/$PROFILE/before-emerge.sh $GENTOO_DIR/
[ -f profile/$PROFILE/after-emerge.sh ] && $SUDO ln -f profile/$PROFILE/after-emerge.sh $GENTOO_DIR/

$SUDO mkdir -p cache/profile/$PROFILE
if file -L $GENTOO_DIR/bin/sh | grep -q 80386; then
	SETARCH="setarch i686"
fi

$SUDO systemd-nspawn -D "$GENTOO_DIR" --bind=`readlink -f cache/profile/$PROFILE`:/var/cache --bind=/var/db/repos/gentoo $SETARCH /build.sh || exit 1

echo "$STAGE3_HASH" > done-$$.tmp
$SUDO mv done-$$.tmp $GENTOO_DIR/done # mark as built
