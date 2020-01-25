#!/bin/sh

source ./config

WORKER_NAME=`hostname`

if [ -z "$XMR_ADDR" -o -z "$XMR_POOL" ]; then
	echo "XMR_ADDR or XMR_POOL is not set."
	exit 1
fi

wrmsr -a 0xc0011022 0x510000
wrmsr -a 0xc001102b 0x1808cc16
wrmsr -a 0xc0011020 0

echo 3 > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages

while true; do
        ./xmr-stak-rx --currency monero -o $XMR_POOL -u $XMR_ADDR.$WORKER_NAME -p x --noNVIDIA --noAMD --noTest
        [ $? -lt 128 ] && break
done
