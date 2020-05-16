import {pkg,mkdir} from "./collect.ts"
pkg("dev-lang/jimtcl")
//dev-libs/libusb
pkg("sys-apps/usb_modeswitch", {use:["jimtcl"]})
mkdir("/var/lib/usb_modeswitch")
