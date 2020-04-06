#!/bin/sh
if [ -x before-emerge.sh ]; then
	./before-emerge.sh || exit 1
fi

if [ -d /var/db/repos/localrepo ]; then
		emerge -uDN -bk --binpkg-respect-use=y repoman
		pushd /var/db/repos/localrepo && repoman manifest
		popd
		mkdir -p /etc/portage/repos.conf
	  echo -e '[localrepo]\nlocation = /var/db/repos/localrepo' > /etc/portage/repos.conf/localrepo.conf
		mkdir -p /var/db/repos/localrepo/{metadata,profiles}
		chown -R portage:portage /var/db/repos/localrepo
		echo 'localrepo' > /var/db/repos/localrepo/profiles/repo_name
		echo -e "masters = gentoo\nauto-sync = false" > /var/db/repos/localrepo/metadata/layout.conf
fi

emerge -uDN -bk --binpkg-respect-use=y system gentoolkit

if [ -f /etc/portage/sets/kernel ]; then
	USE="symlink" emerge -uDN -bk --binpkg-respect-use=y @kernel genkernel eclean-kernel squashfs-tools || exit 1
	./genkernel.sh || exit 1
fi

if [ -f /etc/portage/sets/all-pre ]; then
	emerge -uDN -bk --binpkg-respect-use=y @all-pre || exit 1
fi

if [ -f /etc/portage/sets/all ]; then
	emerge -uDN -bk --binpkg-respect-use=y @all || exit 1
fi

if [ -f modules_need_to_be_rebuilt ]; then
	emerge -b @module-rebuild || exit 1
	rm -f modules_need_to_be_rebuilt
fi

if [ -f /init.c ]; then
	if grep -q '#define INIFILE' /init.c; then
		gcc -lblkid -lmount -liniparser init.c -o /init || exit 1
	else
		gcc -lblkid -lmount init.c -o /init || exit 1
	fi
fi

if [ -f /initramfs.lst ]; then
	cat /initramfs.lst | cpio -D / -H newc -L -o > /tmp/initramfs || exit 1
	rm -f /boot/initramfs
	xz -c --check=crc32 /tmp/initramfs > /boot/initramfs || exit 1
fi

emerge -uDN world
emerge --depclean
[ -x /usr/bin/eclean-kernel ] && eclean-kernel -n 1

etc-update --automode -5

if [ -f rdepends ]; then
	truncate -c -s 0 rdepends
	for i in /var/db/pkg/*/*/RDEPEND; do
        	CATEGORY=$(cat `dirname $i`/CATEGORY)
        	PF=$(cat `dirname $i`/PF | sed 's/-r[0-9]\+$//' | sed 's/-[^-]\+$//')
        	RDEPEND=$(cat $i)
        	echo -e "$CATEGORY/$PF\t$RDEPEND" >> rdepends
	done
fi

if [ -x after-emerge.sh ]; then
	./after-emerge.sh || exit 1
fi

eclean-dist -d
eclean-pkg -d

exit 0
