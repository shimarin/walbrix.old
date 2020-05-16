import {pkg,mkdir} from "./collect.ts"
pkg("sys-cluster/drbd-utils")
mkdir("/var/lib/drbd")
