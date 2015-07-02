#!/bin/sh
if [ "$#" -ne 1 ]; then
	echo "Usage: $0 kerneldir"
	exit 1
fi

genkernel --no-mountboot --kerneldir=$1 bzImage

