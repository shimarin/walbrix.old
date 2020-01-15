#!/bin/sh
emerge -uDN -bk --binpkg-respect-use=y system gentoo-sources genkernel app-arch/lz4 || exit 1
./genkernel.sh || exit 1
if [ -f /etc/portage/sets/all-pre ]; then
	emerge -uDN -bk --binpkg-respect-use=y @all-pre || exit 1
fi
emerge -uDN -bk --binpkg-respect-use=y @all || exit 1
