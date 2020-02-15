BASEDIR=http://ftp.iij.ad.jp/pub/linux/gentoo/releases/x86/autobuilds/
FILENAME=$(wget -q -O - ${BASEDIR}latest-stage3-i686-systemd.txt | egrep -v '^#' | awk '{print $1}'|head -n 1) 
if [ -z "$FILENAME" ]; then
	exit 1
fi
echo ${BASEDIR}${FILENAME}
