import {pkg,mkdir} from "./collect.ts"
pkg("app-admin/sudo", {exclude:'^/usr/share/examples/',use:["-sendmail","pam"]})
mkdir("/etc/sudoers.d")
