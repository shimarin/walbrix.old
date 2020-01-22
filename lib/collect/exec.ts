import * as fs from "fs-extra";
import * as path from "path";
import * as child_process from "child_process";
import {Context} from "./context";
import {chroot} from "../chroot";

export function exec(context:Context, command:string,
  options?:{overlay?:boolean, ldconfig?:boolean, cache?:string, no_proc?:boolean,no_shm?:boolean,no_pts?:boolean})
{
  if (options?.ldconfig) {
    console.log("ldconfig")
    child_process.spawnSync("chroot", [context.dstdir, "ldconfig"], {stdio:"inherit"});
  }

  if (options?.cache) {
    const cache_dir = path.join("cache/collect", options.cache);
    fs.mkdirpSync(cache_dir);
    if (child_process.spawnSync("rsync",
      ["-a", cache_dir + '/', path.join(context.dstdir, "/var/cache")], {stdio:"inherit"}).status !== 0) {
      throw new Error("cache sync failed");
    }
    // sync cache
  }
  try {
    console.log("E " + command);
    if (chroot(context.dstdir, command,
        {lower_layer:options?.overlay? context.srcdir : undefined, no_proc:options?.no_proc, no_shm:options?.no_shm, no_pts:options?.no_pts}) !== 0) {
      throw new Error(`Execution failed: '${command}'`);
    }
  }
  finally {
    if (options?.cache) {
      if (child_process.spawnSync("rsync",
          ["-a", "--delete", path.join(context.dstdir, "/var/cache") + '/', path.join("cache/collect", options.cache)],
          {stdio:"inherit"}).status !== 0) {
        console.log("cache sync back failed.");
      }
    }
  }
}
