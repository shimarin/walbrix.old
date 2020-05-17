import {f,kernel,dir,pkg,write,sed,symlink,mkdir,touch,exec,copy,env} from "./collect.ts"

await import("./base.ts")

dir("/lib/firmware")

import("./kbd-minimal.ts")
import("./xfsprogs.ts")

pkg("dosfstools")
pkg("parted")
await import("./grub.ts")
mkdir("/boot/grub")
copy("resource/walbrix/grub.cfg", "/boot/grub/grub.cfg")
await copy("resource/walbrix/background.png", "/boot/grub/")
sed("/boot/grub/grub.cfg", `s/__VERSION__/${env["KERNEL_VERSION"].replace(/-.+$/, "")}/g`)

// hwids
f(
  "/bin/sed",
  "/usr/sbin/lspci",
  "/usr/share/misc/pci.ids.gz",
  "/usr/share/misc/usb.ids.gz"
)


await import("./wireless-tools.ts")
write("/etc/hostapd/hostapd.conf", "interface=wlan0\nbridge=xenbr0\n#driver=nl80211\nhw_mode=g\nssid=walbrix-ap\nwpa_passphrase=secret\nwpa=2\n#channel=11\nwpa_key_mgmt=WPA-PSK\nwpa_pairwise=CCMP")

pkg("app-misc/ca-certificates")
pkg("app-misc/mime-types")
pkg("app-misc/pax-utils")
import("./openssl.ts")
//#$package sys-apps/haveged

write("/etc/hostname", "WBFREE01")

// tools
pkg("screen")
import("./sudo.ts")
f(
  "/usr/bin/ftp",
  "/usr/bin/stress"
)
pkg("app-editors/bvi")
pkg("app-admin/sysstat")
pkg("app-crypt/chntpw")
pkg("sys-process/lsof")
import("./ansible.ts")

// hardware
f (
  "/etc/udev/hwdb.bin",
  "/usr/bin/beep"
  ///usr/bin/cpuid2cpuflags
)
pkg("usbutils")
pkg("lm-sensors")
pkg("lshw")
pkg("sys-apps/dmidecode")
pkg("sys-apps/smartmontools")
import("./usb_modeswitch.ts")
import("./bluez.ts")
pkg("sys-block/megacli")
//#$copy walbrix/arcconf /opt/bin/arcconf
pkg("sys-power/cpupower")
//#$require nut.lst
//#$require omronups.lst
import("./libqmi.ts")
pkg("net-misc/modemmanager")
//#$require gpsd.lst # it still needs python2.7
copy("resource/walbrix/77-mm-docomo-l-03f.rules", "/lib/udev/rules.d/")

// storage/filesystems
f(
  "/usr/bin/lsscsi",
  "/usr/bin/compsize"
)

import("./nfs.ts")
pkg("sys-fs/multipath-tools")
pkg("sys-fs/btrfs-progs")
pkg("sys-fs/squashfs-tools")
pkg("sys-fs/exfat-utils")
pkg("net-fs/cifs-utils", {use:["-acl", "-ads", "-caps"]})
//#$package sys-fs/xfsdump
import("./ntfs3g.ts")
import("./cryptsetup.ts")
pkg("sys-block/nbd")
import("./sg3_utils.ts")
pkg("sys-apps/hdparm")
import("./ddrescue.ts")
pkg("sys-fs/safecopy")
pkg("app-admin/testdisk", {use:"ntfs"})
pkg("sys-apps/gptfdisk")
pkg("app-backup/fsarchiver")
//#$require s3fs.lst
pkg("sys-apps/cciss_vol_status")
await import("./drbd.ts")
//#$patch /etc/xen/scripts/block-drbd xen/block-drbd.patch
import("./open-iscsi.ts")
pkg("sys-fs/bcache-tools")

// MDADM
pkg("sys-fs/mdadm")
exec("systemctl enable mdmonitor")

// LVM
//#$package sys-block/thin-provisioning-tools
pkg("sys-fs/lvm2")
sed("/etc/lvm/lvm.conf", 's/snapshot_autoextend_threshold = 100/snapshot_autoextend_threshold = 80/')
sed("/etc/lvm/lvm.conf", 's/use_lvmetad = 0/use_lvmetad = 1/')
exec("systemctl enable lvm2-lvmetad.socket")

// networks
pkg("net-analyzer/traceroute")
import("./iptables.ts")
f(
  "/usr/bin/cu",
  "/usr/bin/curl",
  "/sbin/brctl",
  "/usr/bin/iperf3"
)
pkg("net-dns/bind-tools")
pkg("net-analyzer/traceroute")
pkg("net-misc/wget")
import("./nmap.ts")
pkg("net-analyzer/netcat")
pkg("net-firewall/ipset")
pkg("net-misc/wakeonlan")
pkg("net-misc/ifenslave")
pkg("net-misc/vconfig")
pkg("net-misc/whois")
pkg("sys-apps/ethtool")
pkg("net-analyzer/snort")
pkg("net-dns/dnsmasq")
import("./ssmtp.ts")
import("./smbclient.ts")
pkg("net-analyzer/net-snmp")

write("/etc/systemd/network/49-xenbr0.netdev", "[NetDev]\nName=xenbr0\nKind=bridge")
write("/etc/systemd/network/50-eth0.network", "[Match]\nName=eth0\n[Network]\nBridge=xenbr0")
write("/etc/systemd/network/52-xenbr0.network", "[Match]\nName=xenbr0\n[Network]\nDHCP=yes\nMulticastDNS=yes\nLLMNR=yes")

await import("./rp-pppoe.ts")
// complementary PPP configs
mkdir("/etc/ppp/chatscripts")
copy("resource/ppp/chatscript-3g", "/etc/ppp/chatscripts/3g")
mkdir("/etc/ppp/peers")
copy("resource/ppp/peer-mineo-d", "/etc/ppp/peers/mineo-d")
copy("resource/ppp/peer-mineo-a", "/etc/ppp/peers/mineo-a")
copy("resource/ppp/peer-interlink", "/etc/ppp/peers/interlink")
copy("resource/ppp/peer-soracom-air", "/etc/ppp/peers/soracom-air")
copy("resource/ppp/ip-up.route.sh", "/etc/ppp/ip-up.d/route.sh")
copy("resource/ppp/ip-down.route.sh", "/etc/ppp/ip-down.d/route.sh")
copy("resource/ppp/connect-ppp", "/usr/sbin/")
copy("resource/ppp/modem-candidates", "/etc/ppp/modem-candidates")
write("/lib/systemd/system/ppp@.service", "[Unit]\nDescription=PPP link to %I\nBefore=network.target\n\n[Service]\nRestart=on-failure\nRestartSec=180s\nExecStart=/usr/sbin/connect-ppp %I\n\n[Install]\nWantedBy=multi-user.target")

// wireless
pkg("net-wireless/wpa_supplicant")
sed("/lib/systemd/system/wpa_supplicant@.service", 's/-i%I$/-i%I -Dnl80211,wext/')
write("/etc/wpa_supplicant/wpa_supplicant-wlan0.conf", 'network={\nscan_ssid=1\nssid="YOUR-SSID"\npsk="YOUR-KEY"\npriority=1\n}')

// extend nf_conntrack capacity
write("/etc/sysctl.conf", 'net.nf_conntrack_max = 65536', {append:true})

import("./timezone-jp.ts")
write("/etc/locale.conf", "LANG=ja_JP.utf8")
write("/etc/vconsole.conf", "KEYMAP=jp106")
mkdir("/etc/X11/xorg.conf.d")
write("/etc/X11/xorg.conf.d/00-keyboard.conf", 'Section "InputClass"\n\tIdentifier "system-keyboard"\n\tMatchIsKeyboard "on"\n\tOption "XkbLayout" "jp"\n\tOption "XkbModel" "jp106"\n\tOption "XkbOptions" "terminate:ctrl_alt_bksp"\nEndSection')

await import("./xen.ts")
sed("/etc/sysconfig/xendomains", "s/^\\(XENDOMAINS_SAVE=.*\\)$/#\\1/")

// VPN
await import("./openvpn.ts")
copy("resource/walbrix/ca.crt", "/etc/openvpn/client/ca.crt")
copy("resource/walbrix/openvpn.conf", "/etc/openvpn/client/openvpn.conf")

// system services
import("./zabbix-agent.ts")
import("./zabbix-proxy.ts")
pkg("dev-vcs/git")
pkg("sys-block/zram-init")
exec("systemctl enable zram_swap")

await import("./kmscon.ts")
exec("systemctl disable getty@tty1")
exec("systemctl enable kmsconvt@tty1")
mkdir("/etc/systemd/system/kmsconvt@tty1.service.d")
write("/etc/systemd/system/kmsconvt@tty1.service.d/walbrix.conf", '[Service]\nExecStart=\nExecStart=/usr/bin/kmscon --login "--vt=%I" --seats=seat0 --no-switchvt -- /usr/sbin/wb login\nRestart=always')
copy("resource/walbrix/installer.target", "/lib/systemd/system/")

copy("resource/install-system-image", "/usr/sbin/")
copy("resource/btrfs/expand-rw-layer", "/usr/sbin/")

// wb
f(
  "/usr/lib64/libgflags.so",
  "/usr/lib64/libiniparser.so.0"
)

copy("wb/.", "/tmp/")
exec("cd /tmp && make clean && make && make install", {overlay:true})
f("/usr/bin/make")
copy("resource/walbrix/wbdomains.service", "/usr/lib/systemd/system/")
exec("systemctl enable wbdomains")
pkg("app-misc/tmux")

// self-build
mkdir("/var/db/repos/gentoo")
pkg("sys-fs/mtools")
f("/usr/bin/xorriso")

// services preferred by installer env
sed("/lib/systemd/system/systemd-networkd.service", 's/^WantedBy=multi-user.target$/WantedBy=multi-user.target installer.target/')
sed("/lib/systemd/system/systemd-resolved.service", 's/^WantedBy=multi-user.target$/WantedBy=multi-user.target installer.target/')
sed("/lib/systemd/system/sshd.service", 's/^WantedBy=multi-user.target$/WantedBy=multi-user.target installer.target/')
exec("systemctl enable systemd-networkd systemd-resolved sshd")
sed("/lib/systemd/system/openvpn-client@.service", 's/^WantedBy=multi-user.target$/WantedBy=multi-user.target installer.target/')
sed("/lib/systemd/system/zabbix-agentd.service", 's/^WantedBy=multi-user.target$/WantedBy=multi-user.target installer.target/')

exec("env-update", {overlay:true})
exec("ldconfig")
