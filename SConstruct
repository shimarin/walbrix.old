#!/usr/bin/python
import os,re,shutil

env = Environment()

env['SYSTEM_64_MARKER'] = "build/walbrix/x86_64/etc/ld.so.cache"
env['SYSTEM_32_MARKER'] = "build/walbrix/i686/etc/ld.so.cache"
env['INSTALLER_64_MARKER'] = "build/installer/x86_64/etc/ld.so.cache"
env['INSTALLER_32_MARKER'] = "build/installer/i686/etc/ld.so.cache"
env['WBUI_MARKER'] = "build/walbrix/wbui/usr/share/wbui/commit-id"
env['LOCALE_MARKER'] = "build/walbrix/locale/.done"
env['MKISOFS_OPTS'] = "-J -r -b boot/boot.img -no-emul-boot -boot-load-size 4 -boot-info-table -graft-points -eltorito-alt-boot -e boot/efiboot.img"
#grub2-mkimage -o files/iso9660/boot.img -O i386-pc-eltorito loopback xfs fat part_gpt part_msdos normal linux echo all_video test multiboot multiboot2 search iso9660 gzio lvm chain configfile cpuid minicmd gfxterm font terminal ata biosdisk squash4

## begin rule defs ##

env.Decider('timestamp-newer')

region_to_locale = {
    "jp":{"locale":"ja_JP","language":"ja"}
}

env.Command("$SYSTEM_64_MARKER", "source/walbrix.x86_64", "rm -rf build/walbrix/x86_64 && ./collect --source source/walbrix.x86_64 --var=ARCH=x86_64 components/walbrix.lst build/walbrix/x86_64")
env.Command("$SYSTEM_32_MARKER", "source/walbrix.i686", "rm -rf build/walbrix/i686 && ./collect --source source/walbrix.i686 --var=ARCH=i686 components/walbrix.lst build/walbrix/i686")
env.Command("$WBUI_MARKER", [Glob("wbui/src/*.py"), "files/walbrix/wb",".git/HEAD"], """
rm -rf build/walbrix/wbui
python2.7 -m compileall -q wbui/src
mkdir -p build/walbrix/wbui/usr/share/wbui && (cd wbui/src && find . themes/default -name 'themes' -prune -o -name '*.pyc' -o -name '*.png' -o -name '*.ogg' -o -name '*.css' -o -name '*.html' |cpio -o -H newc) | (cd build/walbrix/wbui/usr/share/wbui && cpio -idmv --no-preserve-owner)
mkdir -p build/walbrix/wbui/usr/sbin && cp files/walbrix/wb build/walbrix/wbui/usr/sbin/
mkdir -p build/walbrix/wbui/etc/splash/wb/images
cp files/splash/640x480.cfg build/walbrix/wbui/etc/splash/wb/640x480.cfg
cp files/splash/background-640x480.png build/walbrix/wbui/etc/splash/wb/images/background-640x480.png
cp files/splash/verbose-640x480.png build/walbrix/wbui/etc/splash/wb/images/verbose-640x480.png
git rev-parse HEAD|head -c 8 > $TARGET
""")

env.Command("$LOCALE_MARKER", "components/walbrix-ja_JP.lst", """
rm -rf build/walbrix/locale
./collect --source source/walbrix.x86_64 $SOURCE build/walbrix/locale/ja_JP
touch $LOCALE_MARKER
""")

env.Command("build/walbrix/grubvars.cfg", "$WBUI_MARKER", """
echo "set WALBRIX_VERSION=`./kernelver -n source/walbrix.x86_64/boot/kernel`" > $TARGET
echo "set WALBRIX_BUILD_ID=`cat $SOURCE`" >> $TARGET
""")

env.Command("walbrix", ["$SYSTEM_64_MARKER", "$SYSTEM_32_MARKER", "$WBUI_MARKER", "build/walbrix/locale", "build/walbrix/grubvars.cfg"], "mksquashfs build/walbrix $TARGET -noappend")
env.Command("upload", "walbrix", "s3cmd put -P $SOURCE s3://dist.walbrix.net/walbrix")

env.Command("$INSTALLER_64_MARKER", ["components/installer.lst","$LOCALE_MARKER"], "rm -rf build/installer/x86_64 && ./collect --source source/walbrix.x86_64 --var=ARCH=x86_64 components/installer.lst build/installer/x86_64 && cp -av build/walbrix/locale build/installer/x86_64/.locale")
env.Command("$INSTALLER_32_MARKER", ["components/installer.lst","$LOCALE_MARKER"], "rm -rf build/installer/i686 && ./collect --source source/walbrix.i686 --var=ARCH=i686 components/installer.lst build/installer/i686 && cp -av build/walbrix/locale build/installer/i686/.locale")
env.Command("build/installer/install.64", "$INSTALLER_64_MARKER", "(cd build/installer/x86_64 && find .|cpio -o -H newc) | xz -c --check=crc32 > $TARGET")
env.Command("build/installer/install.32", "$INSTALLER_32_MARKER", "(cd build/installer/i686 && find .|cpio -o -H newc) | xz -c --check=crc32 > $TARGET")
env.Command("build/installer/wbui", "$WBUI_MARKER", "(cd build/walbrix/wbui && find .|cpio -o -H newc) | xz -c --check=crc32 > $TARGET")

boot_iso9660 = ["build/boot-iso9660/boot.img","build/boot-iso9660/efiboot.img","build/boot-iso9660/bootx64.efi"]
env.Command(boot_iso9660, "components/boot-iso9660.lst", "rm -rf build/boot-iso9660 && ./collect --source source/walbrix.x86_64 components/boot-iso9660.lst build/boot-iso9660")
env.Command("portage.tar.xz", "/usr/portage/metadata/timestamp.chk", "tar Jcvpf $TARGET --exclude='portage/metadata/cache' --exclude='portage/packages' --exclude='portage/distfiles' -C /usr portage")

for region in ["jp"]:
    # CD
    iso9660_deps = ["walbrix","files/iso9660/grub.cfg","build/installer/install.64","build/installer/install.32","build/installer/wbui"] + boot_iso9660
    iso9660_files = "boot/boot.img=build/boot-iso9660/boot.img boot/efiboot.img=build/boot-iso9660/efiboot.img boot/grub/grub.cfg=files/iso9660/grub.cfg EFI/BOOT/bootx64.efi=build/boot-iso9660/bootx64.efi walbrix=walbrix install.64=build/installer/install.64 install.32=build/installer/install.32 wbui=build/installer/wbui"
    env.Command("walbrix-%s.iso" % region, iso9660_deps, "xorriso -as mkisofs  $MKISOFS_OPTS -V WBINSTALL -o $TARGET %s" % iso9660_files)
    env.Command("walbrix-%s-DVD.iso" % region, iso9660_deps + ["portage.tar.xz"], "xorriso -as mkisofs  $MKISOFS_OPTS -V WBINSTALLDVD -o $TARGET %s portage.tar.xz=portage.tar.xz distfiles=/usr/portage/distfiles" % iso9660_files)

def define_va_target(artifact, arch, region):
    build_dir = "build/%s-%s-%s" % (artifact, arch, region)
    source_dir = "source/va.%s" % arch
    variables = "--var=ARTIFACT=%s --var=ARCH=%s --var=REGION=%s --var=LANGUAGE=%s" % (artifact, arch, region, region_to_locale[region]["language"])
    lstfile = "components/%s.lst" % artifact
    env.Command("%s-%s-%s.tar.xz" % (artifact,arch,region), ["components/%s.lst" % artifact], "./collect --source %s %s %s %s && tar Jcvpf $TARGET -C %s ." % (source_dir, variables, lstfile, build_dir, build_dir))

## end rule defs ##

if len(COMMAND_LINE_TARGETS) > 0:
    regex_va = re.compile(r'^(.+)-(.+)-(.+)\.tar\.xz$')
    for target in COMMAND_LINE_TARGETS:
        va_match = regex_va.match(target)
        if va_match:
            (artifact, arch, region) = va_match.groups()
            define_va_target(artifact, arch, region)

if os.getuid() != 0: raise Exception("You must be a root user.")

if env.GetOption('clean'): shutil.rmtree("build", True)

Default("walbrix")

