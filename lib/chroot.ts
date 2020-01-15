import * as path from "path";
import * as fs from "fs-extra";
import * as child_process from "child_process";
import {quote} from "shell-quote";
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

export function chroot(dir:string, command:string, profile?:string)
{
  const mount_chain:[()=>boolean,()=>boolean][] = [];
  mount_chain.push(
    [()=>{
      fs.ensureDirSync(`${dir}/proc`);
      console.log("Mounting /proc");
      return execSyncQuote("mount", "-t", "proc", "proc", `${dir}/proc`);
    }, ()=>{
      console.log("Unmounting /proc");
      return execSyncQuote("umount", `${dir}/proc`);
    }]
  );
  /*
  mount_chain.push(
    [()=>{
      fs.ensureDirSync(`${dir}/dev`);
      console.log("Mounting /dev");
      return execSyncQuote("mount", "-o", "bind", "/dev", `${dir}/dev`);
    }, ()=>{
      console.log("Unmounting /dev");
      return execSyncQuote("umount", `${dir}/dev`);
    }]
  );
  */
  mount_chain.push(
    [()=>{
      fs.ensureDirSync(`${dir}/dev/shm`);
      console.log("Mounting /dev/shm");
      return execSyncQuote("mount", "-t", "tmpfs", "tmpfs", `${dir}/dev/shm`);
    }, ()=>{
      console.log("Unmounting /dev/shm");
      return execSyncQuote("umount", `${dir}/dev/shm`);
    }]
  );
  mount_chain.push(
    [()=>{
      fs.ensureDirSync(`${dir}/dev/pts`);
      console.log("Mounting /dev/pts");
      return execSyncQuote("mount", "-o", "bind", "/dev/pts",  `${dir}/dev/pts`);
    },()=>{
      console.log("Unmounting /dev/pts");
      return execSyncQuote("umount", `${dir}/dev/pts`);
    }]
  );
  mount_chain.push(
    [()=>{
      fs.ensureDirSync(`${dir}/var/db/repos/gentoo`);
      console.log("Mounting /var/db/repos/gentoo");
      return execSyncQuote("mount", "-o", "bind", "/var/db/repos/gentoo", `${dir}/var/db/repos/gentoo`);
    },()=>{
      console.log("Unmounting /var/db/repos/gentoo");
      return execSyncQuote("umount", `${dir}/var/db/repos/gentoo`);
    }]
  );

  if (profile) {
    mount_chain.push(
      [()=>{
        fs.ensureDirSync(`cache/profile/${profile}`);
        console.log("Mounting /var/cache");
        return execSyncQuote("mount", "-o", "bind", `cache/profile/${profile}`, `${dir}/var/cache`);
      },()=>{
        console.log("Unmounting /var/cache");
        return execSyncQuote("umount", `${dir}/var/cache`);
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
      fs.copyFileSync("/etc/resolv.conf", path.join(dir, "etc/resolv.conf"));
      child_process.spawnSync("chroot", [dir, "/bin/sh", "-c", command], {stdio:"inherit"});
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
    chroot(dir, command, options.profile);
  }
}
