#!/usr/bin/python
import os,re,shutil

env = Environment()

env.Decider('timestamp-newer')
region_to_locale = {
    "jp":{"locale":"ja_JP","language":"ja"}
}

### COMMON components ###

env['WBUI_MARKER'] = "build/wbui/.done"
env['LOCALE_MARKER'] = "build/locale/.done"

env.Command("$WBUI_MARKER", [Glob("wbui/src/*.py"),Glob("wbui/src/*/*.py"), "files/walbrix/wb",".git/HEAD"], """
rm -rf build/wbui
python2.7 -m compileall -q wbui/src
mkdir -p build/wbui/usr/share/wbui && (cd wbui/src && find . themes/default -name 'themes' -prune -o -name '*.pyc' -o -name '*.png' -o -name '*.ogg' -o -name '*.css' -o -name '*.html' |cpio -o -H newc) | (cd build/wbui/usr/share/wbui && cpio -idmv --no-preserve-owner)
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

env.Command("$SYSTEM_64_MARKER", ["$SYSTEM_32_MARKER","source/walbrix.x86_64/var/log/emerge.log", "components/walbrix.lst"], """
rm -rf build/walbrix/x86_64
./collect --source source/walbrix.x86_64 --var=ARCH=x86_64 components/walbrix.lst build/walbrix/x86_64
cp -a build/walbrix/i686/usr/lib/xen/boot/pv-grub2-x86_32.gz build/walbrix/x86_64/usr/lib/xen/boot/
touch $TARGET
""")

env.Command("$SYSTEM_32_MARKER", ["source/walbrix.i686/var/log/emerge.log", "components/walbrix.lst"], """
rm -rf build/walbrix/i686
./collect --source source/walbrix.i686 --var=ARCH=i686 components/walbrix.lst build/walbrix/i686
touch $TARGET
""")

env.Command("build/walbrix/walbrix.cfg", ["$SYSTEM_64_MARKER","$SYSTEM_32_MARKER","$WBUI_MARKER"], """
echo "set WALBRIX_VERSION=`./kernelver -n source/walbrix.x86_64/boot/kernel`" > $TARGET
echo "set WALBRIX_BUILD_ID=`cat build/wbui/usr/share/wbui/commit-id`" >> $TARGET
echo "set WALBRIX_UPDATE_URL=http://update.walbrix.net" >> $TARGET
""")

env.Command("build/walbrix/.done", ["$SYSTEM_64_MARKER", "$SYSTEM_32_MARKER","build/walbrix/walbrix.cfg","files/walbrix/grub.cfg","files/walbrix/install.cfg","files/walbrix/background.png"], """
cp files/walbrix/grub.cfg files/walbrix/install.cfg files/walbrix/background.png build/walbrix/
touch $TARGET
""")

env.Command("walbrix", ["build/walbrix/.done", "$WBUI_MARKER", "$LOCALE_MARKER"], "mksquashfs build/walbrix/* build/wbui build/locale $TARGET -noappend")
env.Command("upload", "walbrix", "s3cmd put -P $SOURCE s3://dist.walbrix.net/walbrix")
env.Command("install", ["walbrix","/.overlay/boot/walbrix"],"""
mount -o rw,remount /.overlay/boot
[ ! -f /.overlay/boot/walbrix.cur ] && mv /.overlay/boot/walbrix /.overlay/boot/walbrix.cur
cp walbrix /.overlay/boot/walbrix
mount -o ro,remount /.overlay/boot
""") 

### DESKTOP ###

env['DESKTOP_32_MARKER'] = "build/desktop/i686/.done"

env.Command("$DESKTOP_32_MARKER", ["source/desktop.i686/var/log/emerge.log","components/desktop.lst"], """
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

### INSTALLER(CD/DVD-ROM) ###

env['INSTALLER_64_MARKER'] = "build/installer/x86_64/.done"
env['INSTALLER_32_MARKER'] = "build/installer/i686/.done"
env['MKISOFS_OPTS'] = "-f -J -r -b boot/boot.img -no-emul-boot -boot-load-size 4 -boot-info-table -graft-points -eltorito-alt-boot -e boot/efiboot.img"

env.Command("$INSTALLER_64_MARKER", ["source/walbrix.x86_64/var/log/emerge.log","components/installer.lst","$LOCALE_MARKER"], """
rm -rf build/installer/x86_64
./collect --source source/walbrix.x86_64 --var=ARCH=x86_64 components/installer.lst build/installer/x86_64
cp -av build/locale build/installer/x86_64/.locale
touch $TARGET
""")

env.Command("$INSTALLER_32_MARKER", ["source/walbrix.i686/var/log/emerge.log","components/installer.lst","$LOCALE_MARKER"], """
rm -rf build/installer/i686
./collect --source source/walbrix.i686 --var=ARCH=i686 components/installer.lst build/installer/i686
cp -av build/locale build/installer/i686/.locale
touch $TARGET
""")

env.Command("build/installer/install.64", "$INSTALLER_64_MARKER", "(cd build/installer/x86_64 && find .|cpio -o -H newc) | xz -c --check=crc32 > $TARGET")
env.Command("build/installer/install.32", "$INSTALLER_32_MARKER", "(cd build/installer/i686 && find .|cpio -o -H newc) | xz -c --check=crc32 > $TARGET")
env.Command("build/installer/wbui", "$WBUI_MARKER", "(cd build/wbui && find .|cpio -o -H newc) | xz -c --check=crc32 > $TARGET")

boot_iso9660 = ["build/boot-iso9660/boot.img","build/boot-iso9660/efiboot.img","build/boot-iso9660/bootx64.efi"]
env.Command(boot_iso9660, "components/boot-iso9660.lst", "rm -rf build/boot-iso9660 && ./collect --source source/walbrix.x86_64 components/boot-iso9660.lst build/boot-iso9660")
env.Command("portage.tar.xz", "/usr/portage/metadata/timestamp.chk", "tar Jcvpf $TARGET --exclude='portage/metadata/cache' --exclude='portage/packages' --exclude='portage/distfiles' -C /usr portage")

for region in ["jp"]:
    # CD
    iso9660_deps = ["$SYSTEM_64_MARKER","files/iso9660/grub.cfg","build/installer/install.32","build/installer/wbui"] + boot_iso9660
    iso9660_files = "boot/boot.img=build/boot-iso9660/boot.img boot/efiboot.img=build/boot-iso9660/efiboot.img boot/grub/grub.cfg=files/iso9660/grub.cfg boot/grub/fonts/unicode.pf2=build/walbrix/i686/usr/share/grub/unicode.pf2 EFI/BOOT/bootx64.efi=build/boot-iso9660/bootx64.efi kernel.32=build/walbrix/i686/boot/kernel install.32=build/installer/install.32 wbui=build/installer/wbui EFI/Walbrix/kernel=build/walbrix/x86_64/boot/kernel EFI/Walbrix/initramfs=build/walbrix/x86_64/boot/initramfs"
    env.Command("walbrix-%s.iso" % region, iso9660_deps + ["walbrix"], "xorriso -as mkisofs $MKISOFS_OPTS -V WBINSTALL -o $TARGET %s walbrix=walbrix" % iso9660_files)
    env.Command("desktop-%s.iso" % region, iso9660_deps + ["desktop"], "xorriso -as mkisofs $MKISOFS_OPTS -V WBINSTALL -o $TARGET %s walbrix=desktop" % iso9660_files)
    env.Command("walbrix-%s-DVD.iso" % region, iso9660_deps + ["walbrix" + "portage.tar.xz"], "xorriso -as mkisofs  $MKISOFS_OPTS -V WBINSTALLDVD -o $TARGET %s walbrix=walbrix portage.tar.xz=portage.tar.xz distfiles=/usr/portage/distfiles" % iso9660_files)


### VIRTUAL APPLIANCES ###

def define_va_target(artifact, arch, region):
    build_dir = "build/%s-%s-%s" % (artifact, arch, region)
    source_dir = "source/va.%s" % arch
    variables = "--var=ARTIFACT=%s --var=ARCH=%s --var=REGION=%s --var=LANGUAGE=%s" % (artifact, arch, region, region_to_locale[region]["language"])
    lstfile = "components/%s.lst" % artifact
    env.Command("%s-%s-%s.tar.xz" % (artifact,arch,region), ["components/%s.lst" % artifact], "rm -rf %s && ./collect --source %s %s %s %s && tar Jcvpf $TARGET -C %s ." % (build_dir, source_dir, variables, lstfile, build_dir, build_dir))

if len(COMMAND_LINE_TARGETS) > 0:
    regex_va = re.compile(r'^(.+)-(.+)-(.+)\.tar\.xz$')
    for target in COMMAND_LINE_TARGETS:
        va_match = regex_va.match(target)
        if va_match:
            (artifact, arch, region) = va_match.groups()
            define_va_target(artifact, arch, region)

### end rule defs ###

if os.getuid() != 0: raise Exception("You must be a root user.")

if env.GetOption('clean'): shutil.rmtree("build", True)

Default("walbrix")
