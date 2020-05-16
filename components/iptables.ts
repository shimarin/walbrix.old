import {pkg,touch,exec} from "./collect.ts"
touch("/var/lib/iptables/rules-save")
touch("/var/lib/ip6tables/rules-save")
exec("chmod 600 /var/lib/iptables/rules-save /var/lib/ip6tables/rules-save")
exec("ystemctl enable iptables-restore iptables-store ip6tables-restore ip6tables-store")
