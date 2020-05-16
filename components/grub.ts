import {f,pkg} from "./collect.ts"

//sys-libs/efivar
pkg("sys-apps/pciutils")
//sys-boot/efibootmgr
pkg("sys-boot/grub") // USE="device-mapper grub_platforms_efi-64 grub_platforms_pc grub_platforms_xen"
f("/usr/sbin/efibootmgr","/usr/bin/efivar")
