#!/bin/sh
WORKER_NAME=`hostname`

source ./config

if [ -z "$ETH_ADDR" -o -z "$ETH_POOL" ]; then
	echo "ETH_ADDR or ETH_POOL is not set."
	exit 1
fi

if [ -z "$ETC_ADDR" -o -z "$ETC_POOL" ]; then
	echo "ETC_ADDR or ETC_POOL is not set."
	exit 1
fi

case $ECOIN in
  "etc" ) ECOIN_OPTS="-epool $ETC_POOL -ewal $ETC_ADDR/$WORKER_NAME/$EMAIL" ;;
  "eth" ) ECOIN_OPTS="-epool $ETH_POOL -ewal $ETH_ADDR/$WORKER_NAME/$EMAIL" ;;
  * ) echo "ECOIN is not set or unknown ecoin" && exit 1 ;;
esac

case $DCOIN in
  * ) DCOIN_OPTS="-mode 1" ;;
esac

PLATFORM=0

# for AMD cards
if [ -d /sys/module/amdgpu ]; then
        for i in /sys/class/drm/card*/device; do
                [ -f $i/power_dpm_force_performance_level ] || continue
                echo manual > $i/power_dpm_force_performance_level
                case `cat $i/vbios_version` in
                        "113-D0003400_100" ) CLK="s 1 1100 850\nm 1 2100 850" ;;
                        "113-2E3471U.O56" ) CLK="s 1 900 800\nm 1 1500 800" ;;
                        "113-C98121-H01" | "113-C98121-M01" ) CLK="s 1 1000 850\nm 1 2000 850" ;;
                        "113-D00034-S07" ) CLK="s 1 1130 850\nm 1 2150 850" ;;
                        "xxx-xxx-xxx" ) CLK="s 1 1130 850\nm 1 2150 850" ;;
                        "113-349PRO4-U45" ) CLK="s 1 1000 850\nm 1 1900 850" ;;
                        * ) CLK="s 1 1000 800\nm 1 1900 800" ;;
                esac
                echo -e $CLK > $i/pp_od_clk_voltage
                echo -e $CLK
                echo "c" > $i/pp_od_clk_voltage
                echo 1 > $i/pp_dpm_sclk
                echo 1 > $i/pp_dpm_mclk
        done
        PLATFORM=$((PLATFORM + 1))
fi

if [ -d /sys/module/nvidia ]; then
        nvidia-smi -pm 1
        nvidia-smi -L|while read line; do
                num=`echo ${line}|sed 's/^GPU \([0-9]\+\): .\+$/\1/'`
                echo $line | grep "1050" && $NVIDIA_SMI -i $num -pl 52.5
                echo $line | grep "1060" && $NVIDIA_SMI -i $num -pl 65.0
                echo $line | grep "1070 Ti" && $NVIDIA_SMI -i $num -pl 98.5
        done
        PLATFORM=$((PLATFORM + 2))
fi

if [ $PLATFORM -eq 0 ]; then
        echo "No GPU platforms detected."
        exit 1
fi

./ethdcrminer64 -platform $PLATFORM $ECOIN_OPTS -esm 2 -epsw x $DCOIN_OPTS -dpsw x -dcri 7 -ftime 10 -wd 0 -eres 4 -etha 2
