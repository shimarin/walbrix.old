import {f,pkg,mkdir} from "./collect.ts"
pkg("net-fs/samba", {use:["client","winbind"],nocopy:true})
f("/usr/bin/nmblookup","/usr/bin/smbclient","/usr/lib64/libnss_wins.so")
mkdir("/var/cache/samba")
