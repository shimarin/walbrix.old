import {f,sed} from "./collect.ts"
f(
  "/etc/init.d/zabbix-agentd",
  "/etc/zabbix/.keep_net-analyzer_zabbix-0",
  "/etc/zabbix/zabbix_agentd.conf",
  "/usr/bin/zabbix_get",
  "/usr/bin/zabbix_sender",
  "/usr/sbin/zabbix_agentd",
  "/var/log/zabbix/.keep_net-analyzer_zabbix-0",
  "/lib/systemd/system/zabbix-agentd.service"
)
sed("/etc/zabbix/zabbix_agentd.conf", 's/^Hostname=.\+/# Hostname=/')
