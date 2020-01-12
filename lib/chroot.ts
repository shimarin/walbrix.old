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

export function chroot(dir:string, command:string)
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
  try {
    fs.statSync(`${dir}/usr/portage/metadata/timestamp`);
  }
  catch (noexist) {
    mount_chain.push(
      [()=>{
        fs.ensureDirSync(`${dir}/usr/portage`);
        console.log("Mounting /usr/portage");
        return execSyncQuote("mount", "-o", "bind", "/usr/portage", `${dir}/usr/portage`);
      },()=>{
        return execSyncQuote("umount", `${dir}/usr/portage`);
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
  options = [];

  public run(dir:string,command:string = "/bin/bash",options:Command) {
    if (process.getuid() !== 0) {
      console.log("You must be a root user.")
      process.exit(-1);
    }
    //else
    chroot(dir, command);
  }
}
