import {pkg,touch,exec} from "./collect.ts"

pkg("net-firewall/iptables")
touch("/var/lib/iptables/rules-save")
touch("/var/lib/ip6tables/rules-save")
exec("chmod 600 /var/lib/iptables/rules-save /var/lib/ip6tables/rules-save")
exec("systemctl enable iptables-restore iptables-store ip6tables-restore ip6tables-store")
