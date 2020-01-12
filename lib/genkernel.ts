import {cpus} from "os";
import {spawnSync} from "child_process";
import * as path from "path";
import * as fs from "fs-extra";
import {Command} from "commander";
import {Subcommand} from "./subcommand";

export class GenKernel implements Subcommand<[string,string,Command]> {
  command = "genkernel <sourcedir> <linuxrc>";
  description = "build a kernel";
  options = [
    ["-r --initramfs", "build initramfs only"] as [string,string]
  ];

  public async run(sourcedir, linuxrc, options:Command) {
    if (process.getuid() !== 0) {
      console.log("You must be a root user.")
      process.exit(-1);
    }

    //else
    fs.copySync(linuxrc, path.join(sourcedir, "tmp/linuxrc"));
    const opts = [
      "--lvm", "--mdadm", "--symlink", "--no-mountboot", "--no-bootloader", "--no-compress-initramfs",
      "--kernel-config=/etc/kernels/kernel-config", "--no-save-config",
      `--makeopts="-j${cpus().length + 1}"`,
      "--linuxrc=/tmp/linuxrc", "--xfsprogs", options.initramfs? "initramfs":"all"
    ]

    const proc_path = path.join(sourcedir, "proc");
    if (spawnSync("mount", ["-t", "proc", "proc", proc_path], {stdio:"inherit"}).status !== 0) {
      console.log("Failed to mount proc filesystem");
      process.exit(-1);
    }

    process.on('SIGINT', () => {
      // ignore SIGINT to ensure unmounting proc
    });
    if (spawnSync("chroot", [sourcedir, "genkernel"].concat(opts), {stdio:"inherit"}).status === 0) {
      spawnSync("chroot", ["diff", "-u", "/etc/kernels/kernel-config", "/usr/src/linux/.config"].concat(opts), {stdio:"inherit"});
    };

//    console.log("Unmounting");
    if (spawnSync("umount", [proc_path]).status !== 0) {
      console.log("Unmounting /proc failed");
    }
  }
}
