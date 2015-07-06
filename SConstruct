#!/usr/bin/python
import os,re,shutil

env = Environment()

## begin rule defs ##

region_to_locale = {
    "jp":{"locale":"ja_JP","language":"ja"}
}

marker_file_system = {
    "x86_64":"build/walbrix/x86_64/etc/ld.so.cache",
    "i686":"build/walbrix/i686/etc/ld.so.cache"
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

env.Command("build/walbrix/locale", "components/walbrix-ja_JP.lst", "./collect --source source/walbrix.x86_64 $SOURCE build/walbrix/locale/ja_JP")

env.Command("build/walbrix/grubvars.cfg", marker_file_wbui, """
echo "set WALBRIX_VERSION=`./kernelver -n source/walbrix.x86_64/boot/kernel`" > $TARGET
echo "set WALBRIX_BUILD_ID=`cat $SOURCE`" >> $TARGET
""")
    
env.Command("walbrix", [marker_file_system["x86_64"], marker_file_system["i686"], marker_file_wbui, "build/walbrix/locale", "build/walbrix/grubvars.cfg"], "mksquashfs build/walbrix $TARGET -noappend")
env.Command("upload", "walbrix", "s3cmd put -P $SOURCE s3://dist.walbrix.net/walbrix")

def define_va_target(artifact, arch, region):
    build_dir = "build/%s-%s-%s" % (artifact, arch, region)
    source_dir = "source/va.%s" % arch
    variables = "--var=ARTIFACT=%s --var=ARCH=%s --var=REGION=%s --var=LANGUAGE=%s" % (artifact, arch, region, region_to_locale[region]["language"])
    lstfile = "components/%s.lst" % artifact
    env.Command("%s-%s-%s.tar.xz" % (artifact,arch,region), ["components/%s.lst" % artifact], "./collect --source %s %s %s %s && tar Jcvpf $TARGET -C %s ." % (source_dir, variables, lstfile, build_dir, build_dir))

## end rule defs ##

if os.getuid() != 0: raise Exception("You must be a root user.")

if env.GetOption('clean'): shutil.rmtree("build", True)

Default("walbrix")

if len(COMMAND_LINE_TARGETS) > 0:
    for target in COMMAND_LINE_TARGETS:
        va_match = re.compile(r'^(.+)-(.+)-(.+)\.tar\.xz$').match(target)
        if va_match:
            (artifact, arch, region) = va_match.groups()
            define_va_target(artifact, arch, region)
