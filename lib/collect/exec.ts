import * as fs from "fs-extra";
import * as path from "path";
import * as child_process from "child_process";
import {Context} from "./context";
import {chroot} from "../chroot";

export function exec(context:Context, command:string, options?:{overlay?:boolean, ldconfig?:boolean})
{
  if (options?.ldconfig) {
    console.log("ldconfig")
    child_process.spawnSync("chroot", [context.dstdir, "ldconfig"], {stdio:"inherit"});
  }
  if (chroot(context.dstdir, command, {lower_layer:options?.overlay? context.srcdir : undefined}) !== 0) {
    throw new Error(`Execution failed: '${command}'`);
  }
}
