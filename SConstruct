#!/usr/bin/python
import os,shutil

env = Environment()

## begin rule defs ##

marker_file_system = {
    "x86_64":"build/walbrix/x86_64/etc/conf.d/hostname",
    "i686":"build/walbrix/i686/etc/conf.d/hostname"
}
marker_file_wbui = "build/walbrix/wbui/usr/share/wbui/commit-id"

for arch in ["x86_64","i686"]:
    env.Command(marker_file_system[arch], "source/walbrix.%s" % arch, "rm -rf build/walbrix/%s && ./collect --source source/walbrix.%s --var=ARCH=%s components/walbrix.lst build/walbrix/%s" % (arch, arch, arch, arch))

env.Command(marker_file_wbui, [Glob("wbui/src/*.pyc"), "files/walbrix/wb",".git/HEAD"], """
rm -rf build/walbrix/wbui
mkdir -p build/walbrix/wbui/usr/share/wbui && (cd wbui/src && find . themes/default -name 'themes' -prune -o -name '*.pyc' -o -name '*.png' -o -name '*.ogg' -o -name '*.css' -o -name '*.html' |cpio -o -H newc) | (cd build/walbrix/wbui/usr/share/wbui && cpio -idmv --no-preserve-owner)
mkdir -p build/walbrix/wbui/usr/sbin && cp files/walbrix/wb build/walbrix/wbui/usr/sbin/
git rev-parse HEAD|head -c 8 > $TARGET
""")

env.Command("build/walbrix/grubvars.cfg", marker_file_wbui, """
echo "set WALBRIX_VERSION=`./kernelver -n source/walbrix.x86_64/boot/kernel`" > $TARGET
echo "set WALBRIX_BUILD_ID=`cat $SOURCE`" >> $TARGET
""")
    
env.Command("walbrix", [marker_file_system["x86_64"], marker_file_system["i686"], marker_file_wbui, "build/walbrix/grubvars.cfg"], "mksquashfs build/walbrix $TARGET -noappend")
env.Command("upload", "walbrix", "s3cmd put -P $SOURCE s3://dist.walbrix.net/walbrix")

Default("walbrix")

## end rule defs ##

if os.getuid() != 0: raise Exception("You must be a root user.")

if env.GetOption('clean'): shutil.rmtree("build", True)
