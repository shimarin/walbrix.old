#!/bin/sh
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

ROOTDIR=`dirname $0`
CHROOT="../../chroot ${ROOTDIR}"
wget -O - `../../find_latest_stage3 i686` | tar jxvpf - -C "${ROOTDIR}" -k -P

USERADD="$CHROOT useradd"
GROUPADD="$CHROOT groupadd"

$GROUPADD -g 124 postmaster
$USERADD -c "added by portage for mailbase" -d /var/spool/mail -u 14 -g 124 -s /sbin/nologin postmaster
$GROUPADD -g 101 openvpn
$USERADD -c "added by portage for openvpn" -d /dev/null -u 101 -g 101 -s /sbin/nologin openvpn
$GROUPADD -g 102 avahi
$USERADD -c "added by portage for avahi" -d /dev/null -u 102 -g 102 -s /sbin/nologin avahi
$GROUPADD -g 103 messagebus
$USERADD -c "added by portage for dbus" -d /dev/null -u 103 -g 103 -s /sbin/nologin messagebus
$GROUPADD -g 104 tcpdump
$USERADD -c "added by portage for tcpdump" -d /dev/null -u 104 -g 104 -s /sbin/nologin tcpdump
$GROUPADD -g 105 zabbix
$USERADD -c "added by portage for zabbix" -d /var/lib/zabbix/home -u 105 -g 105 -s /sbin/nologin zabbix
$GROUPADD -g 106 snort
$USERADD -c "added by portage for snort" -d /dev/null -u 106 -g 106 -s /sbin/nologin snort
$GROUPADD -g 107 dhcp
$USERADD -c "added by portage for dhcp" -d /var/lib/dhcp -u 107 -g 107 -s /sbin/nologin dhcp

$GROUPADD -g 125 crontab
$GROUPADD -g 126 netdev
$GROUPADD -g 127 plugdev
$GROUPADD -g 128 ssmtp

$CHROOT emerge -uDN world || exit 1

