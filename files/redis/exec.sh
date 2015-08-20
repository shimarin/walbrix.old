#!/bin/sh
cd /tmp
redis-server &
PID=$!

sh -c "$*"
RST=$?

kill $PID
wait
exit $RST
