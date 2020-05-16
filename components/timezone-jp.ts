import {exec,symlink} from "./collect.ts"
exec("rm -f /etc/localtime")
symlink("/etc/localtime", "../usr/share/zoneinfo/Asia/Tokyo")
