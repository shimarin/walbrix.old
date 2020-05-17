import {pkg} from "./collect.ts";

await import("./shadow.ts");
pkg("sys-auth/pambase");
pkg("sys-libs/pam");
