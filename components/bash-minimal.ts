import {f} from "./collect.ts";

f(
  "/bin/bash",
  "/etc/bash/bash_logout",
  "/etc/bash/bashrc",
  "/etc/bash/bashrc.d",
  "/bin/sh"
)

import("./terminfo.ts")
