import {f,pkg,sed, exec} from "./collect.ts"

pkg("net-analyzer/fping")

f(
  "/etc/init.d/zabbix-proxy",
  "/etc/zabbix/zabbix_proxy.conf",
  "/lib/systemd/system/zabbix-proxy.service",
  "/usr/lib/tmpfiles.d/zabbix-proxy.conf",
  "/usr/sbin/zabbix_proxy",
  "/usr/share/zabbix/database/sqlite3/schema.sql",
  "/usr/share/zabbix/database/sqlite3/data.sql",
  "/usr/share/zabbix/database/sqlite3/images.sql",
  "/usr/bin/sqlite3"
)

exec("mkdir /var/lib/zabbix && chown zabbix.zabbix /var/lib/zabbix")
sed("/etc/zabbix/zabbix_proxy.conf", 's/^DBName=.*/DBName=\\/var\\/lib\\/zabbix\\/zabbix_proxy.db/')
