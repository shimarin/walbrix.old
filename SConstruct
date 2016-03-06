#!/usr/bin/python
import os,re,shutil

env = Environment()

env.Decider('timestamp-newer')
region_to_locale = {
    "jp":{"locale":"ja_JP","language":"ja"}
}

def lstfile_deps(lstfile, source, region="jp"):
    binutils_conf = os.path.join(source, "etc/ld.so.conf.d/05binutils.conf")
    if not os.path.isfile(binutils_conf): return [lstfile]
    arch_match = re.search(r'^\/usr\/(.+)-pc-linux-gnu\/lib$', open(binutils_conf).read(), re.MULTILINE)
    if arch_match is None: raise Exception("Architecture couldn't be determined")
    arch = arch_match.groups()[0]
    deps_proc = os.popen("./lstfile_deps --source=%s --var=ARCH=%s --var=REGION=%s %s" % (source, arch, region,lstfile))
    deps = deps_proc.read().splitlines()
    if deps_proc.close() != None: raise Exception("lstfile_deps error while processing %s for %s" % (lstfile, source))
    deps += [lstfile, os.path.join(source, "var/log/emerge.log")]
    return deps

### COMMON components ###

env['WBUI_MARKER'] = "build/wbui/.done"
env['LOCALE_MARKER'] = "build/locale/.done"

env.Command("$WBUI_MARKER", [Glob("wbui/src/*.py"),Glob("wbui/src/*/*.py"), "files/walbrix/wb",".git/HEAD"], """
rm -rf build/wbui
python2.7 -m compileall -q wbui/src
mkdir -p build/wbui/usr/share/wbui && (cd wbui/src && find . themes/default -name 'themes' -prune -o -name '*.pyc' -o -name '*.png' -o -name '*.ogg' -o -name '*.css' -o -name '*.js' -o -name '*.ico' -o -name '*.html' |cpio -o -H newc) | (cd build/wbui/usr/share/wbui && cpio -idmv --no-preserve-owner)
mkdir -p build/wbui/usr/sbin && cp files/walbrix/wb build/wbui/usr/sbin/
mkdir -p build/wbui/etc/splash/wb/images
cp files/splash/640x480.cfg build/wbui/etc/splash/wb/640x480.cfg
cp files/splash/background-640x480.png build/wbui/etc/splash/wb/images/background-640x480.png
cp files/splash/verbose-640x480.png build/wbui/etc/splash/wb/images/verbose-640x480.png
git rev-parse HEAD|head -c 8 > build/wbui/usr/share/wbui/commit-id
touch $TARGET
""")

env.Command("$LOCALE_MARKER", "components/walbrix-ja_JP.lst", """
rm -rf build/locale
./collect --source source/walbrix.x86_64 $SOURCE build/locale/ja_JP
touch $TARGET
""")

### WALBRIX ###

env['SYSTEM_64_MARKER'] = "build/walbrix/x86_64/.done"
env['SYSTEM_32_MARKER'] = "build/walbrix/i686/.done"

env.Command("$SYSTEM_64_MARKER", lstfile_deps("components/walbrix.lst","source/walbrix.x86_64"), """
rm -rf build/walbrix/x86_64
./collect --source source/walbrix.x86_64 --var=ARCH=x86_64 components/walbrix.lst build/walbrix/x86_64
./kernelver -n build/walbrix/x86_64/boot/kernel > $TARGET
""")

env.Command("$SYSTEM_32_MARKER", lstfile_deps("components/walbrix.lst","source/walbrix.i686"), """
rm -rf build/walbrix/i686
./collect --source source/walbrix.i686 --var=ARCH=i686 components/walbrix.lst build/walbrix/i686
./kernelver -n build/walbrix/i686/boot/kernel > $TARGET
""")

env.Command("build/walbrix/walbrix.cfg", ["$SYSTEM_64_MARKER","$SYSTEM_32_MARKER","$WBUI_MARKER"], """
#[ "`cat $SYSTEM_64_MARKER`" = "`cat $SYSTEM_32_MARKER`" ]
echo "set WALBRIX_VERSION=`cat $SYSTEM_64_MARKER`" > $TARGET
echo "set WALBRIX_BUILD_ID=`cat build/wbui/usr/share/wbui/commit-id`" >> $TARGET
echo "set WALBRIX_UPDATE_URL=http://update.walbrix.net" >> $TARGET
""")

env.Command("build/walbrix/.done", ["$SYSTEM_64_MARKER", "$SYSTEM_32_MARKER","build/walbrix/walbrix.cfg","files/walbrix/grub.cfg","files/walbrix/install.cfg","files/walbrix/background.png"], """
cp files/walbrix/grub.cfg files/walbrix/install.cfg files/walbrix/background.png build/walbrix/
touch $TARGET
""")

env.Command("walbrix", ["build/walbrix/.done", "$WBUI_MARKER", "$LOCALE_MARKER"], """
mksquashfs build/walbrix/* build/wbui build/locale $TARGET -noappend
echo s3cmd put -P $TARGET s3://dist.walbrix.net/walbrix
""")
env.Command("install", ["walbrix","/.overlay/boot/walbrix"],"""
mount -o rw,remount /.overlay/boot
[ ! -f /.overlay/boot/walbrix.cur ] && mv /.overlay/boot/walbrix /.overlay/boot/walbrix.cur
cp walbrix /.overlay/boot/walbrix
mount -o ro,remount /.overlay/boot
""")

### DESKTOP ###

env['DESKTOP_32_MARKER'] = "build/desktop/i686/.done"

env.Command("$DESKTOP_32_MARKER", lstfile_deps("components/desktop.lst","source/desktop.i686"), """
rm -rf build/desktop/i686
./collect --source source/desktop.i686 --var=ARCH=i686 components/desktop.lst build/desktop/i686
touch $TARGET
""")

env.Command("build/desktop/walbrix.cfg", ["$DESKTOP_32_MARKER","$WBUI_MARKER"], """
echo "set WALBRIX_VERSION=`./kernelver -n source/desktop.i686/boot/kernel`" > $TARGET
echo "set WALBRIX_BUILD_ID=`cat build/wbui/usr/share/wbui/commit-id`" >> $TARGET
echo "set WALBRIX_UPDATE_URL=http://update.walbrix.net/desktop/" >> $TARGET
""")

env.Command("build/desktop/.done", ["$DESKTOP_32_MARKER", "build/desktop/walbrix.cfg", "files/desktop/grub.cfg", "files/desktop/install.cfg", "files/walbrix/background.png"], """
cp files/desktop/grub.cfg files/desktop/install.cfg files/walbrix/background.png build/desktop/
touch $TARGET
""")

env.Command("desktop", ["build/desktop/.done", "$WBUI_MARKER", "$LOCALE_MARKER"], "mksquashfs build/desktop/* build/wbui build/locale $TARGET -noappend")

### INSTALLER ###

env['INSTALLER_64_MARKER'] = "build/installer/x86_64/.done"
env['INSTALLER_32_MARKER'] = "build/installer/i686/.done"
env['MKISOFS_OPTS'] = "-f -J -r -no-emul-boot -boot-load-size 4 -boot-info-table -graft-points -eltorito-alt-boot -e boot/efiboot.img"

env.Command("$INSTALLER_64_MARKER", ["$LOCALE_MARKER"] + lstfile_deps("components/installer.lst", "source/walbrix.x86_64"), """
rm -rf build/installer/x86_64
./collect --source source/walbrix.x86_64 --var=ARCH=x86_64 components/installer.lst build/installer/x86_64
cp -av build/locale build/installer/x86_64/.locale
touch $TARGET
""")

env.Command("$INSTALLER_32_MARKER", ["$LOCALE_MARKER"] + lstfile_deps("components/installer.lst", "source/walbrix.i686"), """
rm -rf build/installer/i686
./collect --source source/walbrix.i686 --var=ARCH=i686 components/installer.lst build/installer/i686
cp -av build/locale build/installer/i686/.locale
touch $TARGET
""")

env.Command("build/installer/install.64", "$INSTALLER_64_MARKER", "(cd build/installer/x86_64 && find .|cpio -o -H newc) | xz -c --check=crc32 > $TARGET")
env.Command("build/installer/install.32", "$INSTALLER_32_MARKER", "(cd build/installer/i686 && find .|cpio -o -H newc) | xz -c --check=crc32 > $TARGET")
env.Command("build/installer/wbui", "$WBUI_MARKER", "(cd build/wbui && find .|cpio -o -H newc) | xz -c --check=crc32 > $TARGET")

boot_iso9660 = ["build/boot-iso9660/boot.img","build/boot-iso9660/efiboot.img","build/boot-iso9660/bootx64.efi"]
env.Command(boot_iso9660, lstfile_deps("components/boot-iso9660.lst","source/walbrix.x86_64"), "rm -rf build/boot-iso9660 && ./collect --source source/walbrix.x86_64 components/boot-iso9660.lst build/boot-iso9660")

for region in ["jp"]:
    # CD
    iso9660_deps = ["$SYSTEM_64_MARKER","files/iso9660/grub.cfg","files/iso9660/isolinux.cfg","build/installer/install.32","build/installer/wbui"] + boot_iso9660 + ["source/walbrix.i686/usr/share/syslinux/isolinux.bin","source/walbrix.i686/usr/share/syslinux/libutil.c32","source/walbrix.i686/usr/share/syslinux/ldlinux.c32","source/walbrix.i686/usr/share/syslinux/menu.c32"]
    iso9660_files = "boot/boot.img=build/boot-iso9660/boot.img boot/efiboot.img=build/boot-iso9660/efiboot.img boot/grub/grub.cfg=files/iso9660/grub.cfg boot/grub/fonts/unicode.pf2=build/walbrix/i686/usr/share/grub/unicode.pf2 EFI/BOOT/bootx64.efi=build/boot-iso9660/bootx64.efi boot/isolinux/isolinux.bin=source/walbrix.i686/usr/share/syslinux/isolinux.bin boot/isolinux/libutil.c32=source/walbrix.i686/usr/share/syslinux/libutil.c32 boot/isolinux/ldlinux.c32=source/walbrix.i686/usr/share/syslinux/ldlinux.c32 boot/isolinux/menu.c32=source/walbrix.i686/usr/share/syslinux/menu.c32 boot/isolinux/isolinux.cfg=files/iso9660/isolinux.cfg kernel.32=build/walbrix/i686/boot/kernel install.32=build/installer/install.32 wbui=build/installer/wbui EFI/Walbrix/kernel=build/walbrix/x86_64/boot/kernel EFI/Walbrix/initramfs=build/walbrix/x86_64/boot/initramfs"
    env.Command("walbrix-%s.iso" % region, iso9660_deps + ["walbrix"], "xorriso -as mkisofs $MKISOFS_OPTS -b boot/boot.img -V WBINSTALL -o $TARGET %s walbrix=walbrix" % iso9660_files)
    env.Command("walbrix-isolinux-%s.iso" % region, iso9660_deps + ["walbrix"], "xorriso -as mkisofs $MKISOFS_OPTS -b boot/isolinux/isolinux.bin -V WBINSTALL -o $TARGET %s walbrix=walbrix" % iso9660_files)
    env.Command("desktop-%s.iso" % region, iso9660_deps + ["desktop"], "xorriso -as mkisofs $MKISOFS_OPTS -V WBINSTALL -o $TARGET %s walbrix=desktop" % iso9660_files)

### SOURCE DVD ###

env.Command("portage.tar.xz", "/usr/portage/metadata/timestamp.chk", """
tar Jcvpf ${TARGET}.tmp --exclude='portage/metadata/cache' --exclude='portage/packages' --exclude='portage/distfiles' -C /usr portage
mv ${TARGET}.tmp ${TARGET}
""")
env.Command("walbrix-sources.iso", "portage.tar.xz", """
./cleanup_distfiles
xorriso -as mkisofs -J -r -graft-points -V WBSOURCE -o $TARGET portage.tar.xz=$SOURCE distfiles=/usr/portage/distfiles x86_64/etc/portage=source/walbrix.x86_64/etc/portage i686/etc/portage=source/walbrix.i686/etc/portage x86_64/etc/kernels=source/walbrix.x86_64/etc/kernels i686/etc/kernels=source/walbrix.i686/etc/kernels x86_64/var/lib/portage/world=source/walbrix.x86_64/var/lib/portage/world i686/var/lib/portage/world=source/walbrix.i686/var/lib/portage/world
[ `stat -c %s walbrix-sources.iso` -le 4704317440 ] && echo "ISO filesize OK."
echo s3cmd put -P walbrix-sources.iso s3://dist.walbrix.net/walbrix-sources-`./kernelver -n source/walbrix.x86_64/boot/kernel`.iso
""")

### VIRTUAL APPLIANCES ###

regex_va = re.compile(r'^(.+)-(.+)-(.+)\.(tar\.xz|squashfs)$')

class VALookup:
    def __init__(self, env):
        self.env = env
        self.nodes = {}
    def lookup(self, name, **kw):
        va_match = regex_va.match(name)
        if va_match is None: return None
        #else
        if name in self.nodes: return self.nodes[name]
        (artifact, arch, region, format) = va_match.groups()
        build_dir = "build/%s-%s-%s" % (artifact, arch, region)
        source_dir = "source/va.%s" % arch
        variables = "--var=ARTIFACT=%s --var=ARCH=%s --var=REGION=%s --var=LANGUAGE=%s" % (artifact, arch, region, region_to_locale[region]["language"])
        lstfile = "components/%s.lst" % artifact
        archive_cmd = ("tar Jcvpf ${TARGET}.tmp --xattrs '--xattrs-include=*' -C %s ." % build_dir) if format == "tar.xz" else ("mksquashfs %s ${TARGET}.tmp -noappend -comp xz" % build_dir)
        node = File(name)
        self.env.Command(node, lstfile_deps(lstfile, source_dir,region), """
rm -rf %s
./collect --source %s %s %s %s
%s
mv ${TARGET}.tmp ${TARGET}
""" % (build_dir, source_dir, variables, lstfile, build_dir, archive_cmd))
        self.nodes[name] = node
        return node

env.lookup_list.append(VALookup(env).lookup)

### end rule defs ###

if os.getuid() != 0: raise Exception("You must be a root user.")

if env.GetOption('clean'): shutil.rmtree("build", True)

Default("walbrix")
