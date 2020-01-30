#!/bin/sh
sed -i 's/^COMMON_FLAGS="-O2 -pipe"$/COMMON_FLAGS="-Os -pipe"/' /etc/portage/make.conf
