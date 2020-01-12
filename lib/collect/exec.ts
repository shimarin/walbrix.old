import * as fs from "fs-extra";
import * as path from "path";
import * as child_process from "child_process";
import {Context} from "./context";
import {chroot} from "../chroot";

export function exec(context:Context, command:string, overlay:boolean)
{
  if (overlay) {
    throw new Error("$exec --overlay is not implemented yet.");
  }
  // else
  chroot(context.dstdir, command);
}
