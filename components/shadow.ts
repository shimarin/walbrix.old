import {f,pkg} from "./collect.ts";

f(
  "/usr/lib/cracklib_dict.pwd",
  "/usr/lib/cracklib_dict.pwi",
  "/etc/passwd",
  "/etc/group",
  "/etc/shadow"
);

pkg("sys-apps/shadow");
