USERID=$(shell id -u)
ifneq ($(USERID),0)
	SUDO=sudo
endif

all: $(patsubst %.artifact,%.squashfs,$(wildcard *.artifact)) bootx64.efi
.PHONY : all

include artifacts.dep

artifacts.dep: *.artifact
	./do.ts artifact2dep $? > $@

%.squashfs: build/%/done
	$(SUDO) mksquashfs $(patsubst build/%/done,build/%,$<) $@ -noappend -comp xz -no-exports -b 1M -Xbcj x86 -e done
	$(SUDO) chown $(USERID) $@

%.tar.xz: build/%/done
	$(SUDO) tar Jcvpf $@ -C $(patsubst build/%/done,build/%,$<) .
	$(SUDO) chown $(USERID) $@

bootx64.efi: bootx64.squashfs build/bootx64/done
	cp build/bootx64/done $@
	dd if=$< of=$@ seek=1 bs=1M

clean:
	rm -f *.squashfs bootx64.efi artifacts.dep
