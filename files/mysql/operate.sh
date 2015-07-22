#!/bin/sh
if [ $# -lt 1 ]; then
    echo "$0 [initdb|createdb|exec]"
    exit 1
fi

CMD=$1
shift

if [ "$CMD" = "initdb" ];then
    echo "initdb"
elif [ "$CMD" = "createdb" ];then
    if [ $# -lt 1 ]; then
        echo "$0 createdb DATABASE [USERNAME [PASSWORD]]"
        exit -1
    fi
    DATABASE=$1
    if [ $# -gt 1 ]; then
        USERNAME=$2
    else
        USERNAME=$DATABASE
    fi
    if [ $# -gt 2 ]; then
        PASSWORD=$3
    fi
elif [ "$CMD" = "exec" ]; then
    if [ $# -lt 2 ]; then
        echo "$0 exec DATABASE SQL [SQL...]"
        exit -1
    fi
    DATABASE=$1
    shift
else
    echo "Invalid command"
    exit -1
fi

MY_DATADIR=/var/lib/mysql
SOCKET=/tmp/mysqld.sock
PIDFILE=/tmp/mysql.pid

if [ "$CMD" = "initdb" ]; then
    mkdir -p $MY_DATADIR
    chown -R mysql:mysql $MY_DATADIR
    chmod 0750 $MY_DATADIR
    /usr/share/mysql/scripts/mysql_install_db --basedir=/usr --cross-bootstrap
fi

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

if [ "$CMD" = "initdb" ]; then
    /usr/bin/mysql_tzinfo_to_sql /usr/share/zoneinfo | /usr/bin/mysql --socket=$SOCKET -uroot mysql
elif [ "$CMD" = "createdb" ]; then
    /usr/bin/mysql --socket=$SOCKET -u root -e "create database \`$DATABASE\`" || FAIL=1
    if [ -z "$PASSWORD" ]; then
        /usr/bin/mysql --socket=$SOCKET -u root -e "grant all privileges on \`$DATABASE\`.* to \`$USERNAME\`@localhost" || FAIL=1
    else
        /usr/bin/mysql --socket=$SOCKET -u root -e "grant all privileges on \`$DATABASE\`.* to \`$USERNAME\`@localhost identified by '$PASSWORD'" || FAIL=1
    fi
elif [ "$CMD" = "exec" ]; then
    IFS=$'\t'
    for sql in $@; do
        /usr/bin/mysql --socket=$SOCKET -u root "$DATABASE" -e "$sql" || FAIL=1
    done
fi

kill `cat $PIDFILE`
rm -f $PIDFILE
wait
while [[ -S "$SOCKET" ]] ; do
	echo -n "."
	sleep 1
done
[ -n "$FAIL" ] && exit 1
exit 0
