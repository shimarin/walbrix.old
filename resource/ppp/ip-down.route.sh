#!/bin/sh
PPP_IFACE="$1"
PPP_LOCAL="$4"
TABLE=$((250+`echo $PPP_IFACE|sed 's/^ppp//'`))
ip rule del from $PPP_LOCAL table $TABLE pref 100

