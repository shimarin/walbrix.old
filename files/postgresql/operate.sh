#!/bin/sh
VERSION=`psql --version|sed 's/.\+\([0-9]\+\.[0-9]\+\)\.[0-9]\+/\1/'`
source /etc/conf.d/postgresql-$VERSION

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
    if [ $# -lt 3 ]; then
        echo "$0 exec DATABASE USERNAME SQL [SQL...]"
        exit -1
    fi
    DATABASE=$1
    USERNAME=$2
    shift
    shift
else
    echo "Invalid command"
    exit -1
fi


if [ "$CMD" = "initdb" ]; then
    unset LANG
    unset LC_CTYPE
    unset LC_NUMERIC
    unset LC_TIME
    unset LC_COLLATE
    unset LC_MONETARY
    unset LC_MESSAGES
    unset LC_ALL
    PG_MAX_CONNECTIONS="128"
    mkdir -p "${DATA_DIR}"
    chown -Rf postgres:postgres "${DATA_DIR}" || exit 1
    chmod 0700 "${DATA_DIR}"

    su postgres -c "/usr/lib/postgresql-$VERSION/bin/initdb -D \"${DATA_DIR}\" ${PG_INITDB_OPTS}" || exit 1
    mv $DATA_DIR/*.conf "${PGDATA}" || exit 1

    ! [ -x /run/postgresql ] && mkdir -p /run/postgresql
    chown postgres:postgres /run/postgresql
fi

su postgres -c "postgres -D ${PGDATA} --data-directory=${DATA_DIR} -c listen_addresses=''" &
PID=$!
sleep 5

if [ "$CMD" = "createdb" ]; then
    createuser -SDR "$USERNAME" -U postgres || FAIL=1
    createdb "$DATABASE" -E utf-8 -T template0 -O "$USERNAME" -U postgres || FAIL=1
    if [ -n "$PASSWORD" ]; then
        psql -U postgres -d "$DATABASE" -c "alter user $USERNAME with password '$PASSWORD'" || FAIL=1
    fi
elif [ "$CMD" = "exec" ]; then
    IFS=$'\t'
    for sql in $@; do
        psql -U postgres -d "$DATABASE" -U "$USERNAME" -c "$sql"
    done
fi

kill $PID
wait
[ -n "$FAIL" ] && exit 1
exit 0
