import * as fs from "fs-extra";
import * as path from "path";
import * as child_process from "child_process";
import {Context} from "./context";

export function exec(context:Context, command:string | string[],
  options?:{overlay?:boolean, ldconfig?:boolean, cache?:string, no_proc?:boolean,no_shm?:boolean,no_pts?:boolean})
{
  if (options?.ldconfig) {
    console.log("ldconfig")
    child_process.spawnSync("chroot", [context.dstdir, "ldconfig"], {stdio:"inherit"});
  }

  const cache_dir = options?.cache? path.join("cache/collect", options.cache) : null;
  if (cache_dir) fs.mkdirpSync(cache_dir);

  const nspawn_args = options?.overlay? [ "-D", context.srcdir, `--overlay=+/:${path.resolve(context.dstdir)}:/` ] : ["-D", context.dstdir];
  const cache_args = cache_dir? [ `--bind=${path.resolve(cache_dir)}:/var/cache`] : [];
  const command_arr = Array.isArray(command)? command : ["/bin/sh", "-c", command];
  const rst = child_process.spawnSync("systemd-nspawn", nspawn_args.concat(cache_args).concat(command_arr), {stdio:"inherit",env:{SYSTEMD_NSPAWN_TMPFS_TMP:"0"}}).status;
  if (rst != 0) {
    throw new Error(`Execution failed: '${command}'`);
  }
}
