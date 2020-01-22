#!/bin/sh
emerge -uDN -bk --binpkg-respect-use=y system

if [ -f /etc/portage/sets/kernel ]; then
	emerge -uDN -bk --binpkg-respect-use=y @kernel genkernel eclean-kernel || exit 1
	./genkernel.sh || exit 1
fi

if [ -f /etc/portage/sets/all-pre ]; then
	emerge -uDN -bk --binpkg-respect-use=y @all-pre || exit 1
fi
emerge -uDN -bk --binpkg-respect-use=y @all || exit 1

if [ -f modules_need_to_be_rebuilt ]; then
	emerge -b @module-rebuild || exit 1
	rm -f modules_need_to_be_rebuilt
fi

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

[ -x /usr/bin/eclean-dist ] && eclean-dist
[ -x /usr/bin/eclean-pkg ] && eclean-pkg

exit 0
