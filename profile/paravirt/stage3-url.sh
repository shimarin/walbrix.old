BASEDIR=http://ftp.iij.ad.jp/pub/linux/gentoo/releases/amd64/autobuilds/
FILENAME=$(wget -q -O - ${BASEDIR}latest-stage3-amd64.txt | egrep -v '^#' | awk '{print $1}'|head -n 1) 
if [ -z "$FILENAME" ]; then
	exit 1
fi
echo ${BASEDIR}${FILENAME}
