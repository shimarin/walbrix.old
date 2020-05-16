import {pkg,symlink} from "./collect.ts"
pkg("dev-lang/python-3.7.7-r2")
symlink("/usr/bin/python", "pytho3.7")
pkg("dev-lang/python-exec")
