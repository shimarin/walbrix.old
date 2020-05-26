#!/bin/sh
if [ -x before-emerge.sh ]; then
	./before-emerge.sh || exit 1
fi

if [ -d /var/db/repos/localrepo ]; then
	emerge -uDN -bk --binpkg-respect-use=y repoman
	pushd /var/db/repos/localrepo && repoman manifest || exit 1
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

if [ -f /init.cpp ]; then
	LIBS="-lblkid -lmount -liniparser"
	if grep -q libxenstore.so /initramfs.lst; then
		LIBS="$LIBS -lxenstore"
	fi
	g++ -std=c++2a $LIBS init.cpp initlib.cpp -o /init || exit 1
elif [ -f /init.c ]; then
	LIBS="-lblkid -lmount"
	if grep -q libiniparser /initramfs.lst; then
		LIBS="$LIBS -liniparser"
	fi
	if grep -q libxenstore /initramfs.lst; then
		LIBS="$LIBS -lxenstore"
	fi
	gcc $LIBS init.c -o /init || exit 1
fi

if grep -q libgcc_s.so /initramfs.lst; then
	cp -L `gcc -print-file-name=libgcc_s.so.1` /usr/lib64/ || exit 1
fi
if grep -q libstdc++.so /initramfs.lst; then
	cp -L `gcc -print-file-name=libstdc++.so.6` /usr/lib64/ || exit 1
fi
if [ -f /initramfs.gen ]; then
	gcc -o /usr/bin/gen_init_cpio /usr/src/linux/usr/gen_init_cpio.c || exit
	GCC_LIBDIR=`gcc -print-file-name=` gen_init_cpio /initramfs.gen > /tmp/initramfs || exit 1
elif [ -f /initramfs.lst ]; then
	cat /initramfs.lst | cpio -D / -H newc -L -o > /tmp/initramfs || exit 1
fi

if [ -f /tmp/initramfs ]; then
	rm -f /boot/initramfs
	xz -c --check=crc32 /tmp/initramfs > /boot/initramfs || exit 1
fi

emerge -uDN world
emerge @preserved-rebuild
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
