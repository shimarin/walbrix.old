#!/bin/sh
VERSION=`psql --version|sed 's/.\+\([0-9]\+\.[0-9]\+\)\.[0-9]\+/\1/'`
source /etc/conf.d/postgresql-$VERSION

su postgres -c "postgres -D ${PGDATA} --data-directory=${DATA_DIR} -c listen_addresses=''" &
PID=$!

while [ ! -S /run/postgresql/.s.PGSQL.5432 ]; do sleep 1; done

PGUSER=postgres sh -c "$*"
RST=$?

kill $PID
wait
exit $RST
