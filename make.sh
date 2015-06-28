#!/bin/sh

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

rm -rf build/walbrix

./collect --source source/walbrix.x86_64 --var=ARCH=x86_64 components/walbrix.lst build/walbrix/x86_64 || exit
./collect --source source/walbrix.i686 --var=ARCH=i686 components/walbrix.lst build/walbrix/i686 || exit

# setup wbui
mkdir -p build/walbrix/wbui/usr/share/wbui build/walbrix/wbui/usr/sbin
find wbui/src -name '*.pyc' -exec rm {} \;
python2.7 -m compileall -q wbui/src
(cd wbui/src && find . themes/default -name 'themes' -prune -o -name '*.pyc' -o -name '*.png' -o -name '*.ogg' -o -name '*.css' -o -name '*.html' |cpio -o -H newc) | (cd build/walbrix/wbui/usr/share/wbui && cpio -idmv --no-preserve-owner)
cp files/walbrix/wb build/walbrix/wbui/usr/sbin/wb
if [ -f .git/HEAD ]; then
    git rev-parse HEAD|head -c 8 >> build/walbrix/wbui/usr/share/wbui/commit-id
fi

# setup splash
mkdir -p build/walbrix/wbui/etc/splash/wb/images
cp files/splash/640x480.cfg build/walbrix/wbui/etc/splash/wb/640x480.cfg
cp files/splash/background-640x480.png build/walbrix/wbui/etc/splash/wb/images/background-640x480.png
cp files/splash/verbose-640x480.png build/walbrix/wbui/etc/splash/wb/images/verbose-640x480.png

# setup locale
./collect --source source/walbrix.x86_64 components/walbrix-ja_JP.lst build/walbrix/locale/ja_JP || exit

# something worth for grub2
echo "set WALBRIX_VERSION=`./kernelver -n source/walbrix.x86_64/boot/kernel`" > build/walbrix/grubvars.cfg
if [ -f build/walbrix/wbui/usr/share/wbui/commit-id ]; then
    echo "set WALBRIX_BUILD_ID=`cat build/walbrix/wbui/usr/share/wbui/commit-id`" >> build/walbrix/grubvars.cfg
fi
cp files/walbrix/grub.cfg build/walbrix/

mksquashfs build/walbrix walbrix.squashfs -noappend

#s3cmd put -P walbrix.squashfs s3://dist.walbrix.net/walbrix
