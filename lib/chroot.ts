import * as path from "path";
import * as fs from "fs-extra";
import * as child_process from "child_process";
import {quote} from "shell-quote";
import * as rimraf from "rimraf";
import {Command} from "commander";
import {Subcommand} from "./subcommand";

function execSyncQuote(...cmdline:string[]):boolean
{
  try {
    child_process.execSync(quote(cmdline));
    return true;
  }
  catch (somethingwrong) {
    return false;
  }
}

export function chroot(orig_dir:string, command:string,
  options?:{profile?:string,lower_layer?:string,no_proc?:boolean,no_shm?:boolean,no_pts?:boolean})
{
  const mount_chain:[()=>boolean,()=>boolean][] = [];

  const overlay_dir = `overlay-${process.pid}`;
  const overlay_root = path.join(overlay_dir, "root");
  const real_dir = options?.lower_layer? overlay_root : orig_dir;

  if (options?.lower_layer) {
    const overlay_work = path.join(overlay_dir, "work");
    mount_chain.push(
      [()=>{
        fs.mkdirpSync(overlay_root);
        fs.mkdirpSync(overlay_work);
        console.log("Mounting overlay");
        return child_process.spawnSync("mount", ["-t", "overlay", "overlay", "-o", `lowerdir=${options.lower_layer},upperdir=${orig_dir},workdir=${overlay_work}`, overlay_root], {stdio:"inherit"}).status === 0;
      }, ()=>{
        console.log("Unmounting overlay");
        const rst = child_process.spawnSync("umount", [overlay_root]).status === 0;
        if (rst) rimraf.sync(overlay_dir);
        return rst;
      }]
    );

  }
  if (!(options?.no_proc)) {
    mount_chain.push(
      [()=>{
        fs.ensureDirSync(`${real_dir}/proc`);
        console.log("Mounting /proc");
        return execSyncQuote("mount", "-t", "proc", "proc", `${real_dir}/proc`);
      }, ()=>{
        console.log("Unmounting /proc");
        return execSyncQuote("umount", `${real_dir}/proc`);
      }]
    );
  }
  if (!(options?.no_shm)) {
    mount_chain.push(
      [()=>{
        fs.ensureDirSync(`${real_dir}/dev/shm`);
        console.log("Mounting /dev/shm");
        return execSyncQuote("mount", "-t", "tmpfs", "tmpfs", `${real_dir}/dev/shm`);
      }, ()=>{
        console.log("Unmounting /dev/shm");
        return execSyncQuote("umount", `${real_dir}/dev/shm`);
      }]
    );
  }
  if (!(options?.no_pts)) {
    mount_chain.push(
      [()=>{
        fs.ensureDirSync(`${real_dir}/dev/pts`);
        console.log("Mounting /dev/pts");
        return execSyncQuote("mount", "-o", "bind", "/dev/pts",  `${real_dir}/dev/pts`);
      },()=>{
        console.log("Unmounting /dev/pts");
        return execSyncQuote("umount", `${real_dir}/dev/pts`);
      }]
    );
  }
  try {
    if (fs.statSync(path.join(real_dir, "/var/db/repos/gentoo")).isDirectory()) {
      mount_chain.push(
        [()=>{
          console.log("Mounting /var/db/repos/gentoo");
          return execSyncQuote("mount", "-o", "bind", "/var/db/repos/gentoo", `${real_dir}/var/db/repos/gentoo`);
        },()=>{
          console.log("Unmounting /var/db/repos/gentoo");
          return execSyncQuote("umount", `${real_dir}/var/db/repos/gentoo`);
        }]
      );
    }
  }
  catch {}

  if (options?.profile) {
    const cache_dir = path.join("cache/profile", options.profile);
    fs.mkdirpSync(cache_dir)
    mount_chain.push(
      [()=>{
        // sync
        console.log("Syncing /var/cache");
        return child_process.spawnSync("rsync", ["-a", `${cache_dir}/`, `${real_dir}/var/cache`], {stdio:"inherit"}).status === 0;
      },()=>{
        // sync back
        console.log("Syncing back /var/cache");
        return child_process.spawnSync("rsync", ["-a", "--delete", `${real_dir}/var/cache/`, cache_dir], {stdio:"inherit"}).status === 0;
      }]
    );
  }

  const unmount_stack:(()=>boolean)[] = [];
  try {
    const all_success = !mount_chain.some( _ => {
      if (_[0]()) {
        unmount_stack.push(_[1]);
        return false;
      }
      else {
        console.log("Mount failed!");
        return true;
      }
    });
    if (all_success) {
      process.on('SIGINT', () => {
        // ignore SIGINT to ensure unmounting stuffs
      });
      //fs.copyFileSync("/etc/resolv.conf", path.join(real_dir, "etc/resolv.conf"));
      return child_process.spawnSync("chroot", [real_dir, "/bin/sh", "-c", command], {stdio:"inherit"}).status;
    }
  }
  finally {
    while (unmount_stack.length > 0) {
      const umount = unmount_stack.pop();
      if (!umount()) {
        console.log("Unmount failed!");
      }
    }
  }
}

export class Chroot implements Subcommand<[string,string,Command]> {
  command = "chroot <dir> [command]";
  description = "perform chroot";
  options = [
    ["-p --profile <profile>", "profile name to apply"] as [string,string]
  ];

  public run(dir:string,command:string = "/bin/bash",options:Command) {
    if (process.getuid() !== 0) {
      console.log("You must be a root user.")
      process.exit(-1);
    }
    //else
    process.exit(chroot(dir, command, {profile:options.profile}));
  }
}
