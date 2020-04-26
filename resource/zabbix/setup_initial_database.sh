#!/bin/sh
MYSQL="/usr/bin/mysql"
$MYSQL -u root -e "create database zabbix" || exit 1
$MYSQL -u root -e 'create user zabbix@localhost; grant all privileges on zabbix.* to zabbix@localhost' || exit 1
$MYSQL -u zabbix zabbix < /usr/share/zabbix/database/mysql/schema.sql || exit 1
$MYSQL -u zabbix zabbix < /usr/share/zabbix/database/mysql/images.sql || exit 1
$MYSQL -u zabbix zabbix < /usr/share/zabbix/database/mysql/data.sql || exit 1
$MYSQL -u zabbix zabbix -e "update users set lang='ja_JP'" || exit 1
$MYSQL -u zabbix zabbix	-e "update media_type set smtp_server='localhost',smtp_helo='example.com',smtp_email='zabbix@example.com' where type=0" || exit 1
$MYSQL -u zabbix zabbix -e "update hosts set status=0 where host='Zabbix server'" || exit 1

