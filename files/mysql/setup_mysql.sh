#!/bin/sh
MY_DATADIR=/var/lib/mysql 
mkdir -p $MY_DATADIR
/usr/share/mysql/scripts/mysql_install_db --basedir=/usr --cross-bootstrap
chown -R mysql:mysql $MY_DATADIR
chmod 0750 $MY_DATADIR
SOCKET=/tmp/mysqld/mysqld.sock
PIDFILE=/tmp/mysql.pid
mkdir /tmp/mysqld && chown mysql /tmp/mysqld
/usr/sbin/mysqld --skip-networking --user=mysql --log-warnings=0 --basedir=/usr\
 --datadir=$MY_DATADIR --max_allowed_packet=8M --net_buffer_length=16K\
 --default-storage-engine=MyISAM --socket=$SOCKET --pid-file=$PIDFILE &
maxtry=15
while ! [[ -S "$SOCKET" || "${maxtry}" -lt 1 ]] ; do
	maxtry=$((${maxtry}-1))
	echo -n "."
	sleep 1
done
if ! [[ -S "$SOCKET" ]]; then
	echo "Failed to start mysqld"
	exit 1
fi
/usr/bin/mysql_tzinfo_to_sql /usr/share/zoneinfo | /usr/bin/mysql --socket=$SOCKET -uroot mysql
kill `cat $PIDFILE`
rm -f $PIDFILE
while [[ -S "$SOCKET" ]] ; do
	echo -n "."
	sleep 1
done
