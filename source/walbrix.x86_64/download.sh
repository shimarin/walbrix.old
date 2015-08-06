#!/bin/sh
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

ROOTDIR=`dirname $0`
wget -O - `${ROOTDIR}/../../find_latest_stage3` | tar jxvpf - -C "${ROOTDIR}" -k -P

