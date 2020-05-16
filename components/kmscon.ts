import {pkg,mkdir,write} from "./collect.ts"

pkg("sys-apps/kmscon")
pkg("media-libs/mesa")
pkg("x11-misc/xkeyboard-config")
pkg("media-fonts/vlgothic")
mkdir("/etc/kmscon")
write("/etc/kmscon/kmscon.conf", '#drm\n#hwaccel')
