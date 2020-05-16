import {f,pkg,sed,write} from "./collect.ts"

pkg("net-wireless/wireless-tools")

//dev-libs/libnl
pkg("net-wireless/wireless-regdb")
//$require m2crypto.lst
//$package net-wireless/crda
pkg("net-wireless/iw")
pkg("net-wireless/wpa_supplicant")
sed("/lib/systemd/system/wpa_supplicant@.service", 's/-i%I$/-i%I -Dnl80211,wext/')
write("/etc/wpa_supplicant/wpa_supplicant-wlan0.conf", 'network={\nscan_ssid=1\nssid="YOUR-SSID"\npsk="YOUR-KEY"\npriority=1\n}')
pkg("net-wireless/hostapd")
f("/usr/sbin/rfkill")
