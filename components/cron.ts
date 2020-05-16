import {f,pkg,exec} from "./collect.ts";

pkg("sys-process/cronbase");
pkg("sys-process/cronie");
f("/bin/run-parts");
exec("systemctl enable cronie");
