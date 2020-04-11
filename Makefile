USERID=$(shell id -u)
ifneq ($(USERID),0)
	SUDO=sudo
endif

all: $(patsubst %.artifact,%.squashfs,$(wildcard *.artifact)) bootx64.efi bootx86.efi
.PHONY : all

include artifacts.dep

artifacts.dep: *.artifact
	./do.ts artifact2dep $? > $@

bootx64.squashfs: build/bootx64/done
	$(SUDO) mksquashfs $(patsubst build/%/done,build/%,$<) $@ -noappend -comp xz -no-exports -b 1M -Xbcj x86 -e done
	$(SUDO) chown $(USERID) $@

bootx86.squashfs: build/bootx86/done
	$(SUDO) mksquashfs $(patsubst build/%/done,build/%,$<) $@ -noappend -comp xz -no-exports -b 1M -Xbcj x86 -e done
	$(SUDO) chown $(USERID) $@

walbrix.squashfs: build/walbrix/done
	$(SUDO) mksquashfs $(patsubst build/%/done,build/%,$<) $@ -noappend -comp xz -no-exports -b 1M -Xbcj x86 -e done
	$(SUDO) chown $(USERID) $@

%.squashfs: build/%/done
	$(SUDO) mksquashfs $(patsubst build/%/done,build/%,$<) $@ -noappend -comp gzip -no-exports -b 1M -e done
	$(SUDO) chown $(USERID) $@

%.tar.xz: build/%/done
	$(SUDO) tar Jcvpf $@ -C $(patsubst build/%/done,build/%,$<) .
	$(SUDO) chown $(USERID) $@

bootx64.efi: bootx64.squashfs build/bootx64/done
	cp build/bootx64/done $@
	dd if=$< of=$@ seek=1 bs=1M

bootx86.efi: bootx86.squashfs build/bootx86/done
	cp build/bootx86/done $@
	dd if=$< of=$@ seek=1 bs=1M

build/bootx64.iso/done: bootx64.efi build/boot-iso9660/done
	$(SUDO) rm -rf build/bootx64.iso && $(SUDO) mkdir -p build/bootx64.iso/efi/boot && $(SUDO) mkdir -p build/bootx64.iso/boot
	$(SUDO) cp build/boot-iso9660/boot.img build/bootx64.iso/boot/
	$(SUDO) cp build/boot-iso9660/efiboot.img build/bootx64.iso/boot/
	$(SUDO) cp bootx64.efi build/bootx64.iso/efi/boot/
	$(SUDO) touch $@

bootx64.iso: build/bootx64.iso/done
	xorriso -as mkisofs -f -J -r -no-emul-boot -boot-load-size 4 -boot-info-table -graft-points -eltorito-alt-boot -e boot/efiboot.img -b boot/boot.img -V WBINSTALL -o bootx64.iso build/bootx64.iso

clean:
	rm -f *.squashfs bootx64.efi artifacts.dep
