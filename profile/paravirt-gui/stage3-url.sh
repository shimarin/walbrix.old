BASEDIR=http://ftp.jaist.ac.jp/pub/Linux/Gentoo/releases/amd64/autobuilds/
FILENAME=$(wget -q -O - ${BASEDIR}latest-stage3-amd64-systemd.txt | egrep -v '^#' | awk '{print $1}'|head -n 1) 
if [ -z "$FILENAME" ]; then
	exit 1
fi
echo ${BASEDIR}${FILENAME}
