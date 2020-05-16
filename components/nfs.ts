import {pkg} from "./collect.ts"
pkg("sys-apps/keyutils")
pkg("net-libs/libtirpc")
pkg("net-nds/rpcbind")
pkg("net-fs/nfs-utils", {use:["-tcpd"]})

//$exec "rm -rf /var/lib/nfs && cp -av /usr/lib/nfs /var/lib/"
