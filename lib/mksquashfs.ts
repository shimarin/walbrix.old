import * as child_process from "child_process";
import {Subcommand} from "./subcommand";

export class MkSquashFS implements Subcommand<[string,string]> {
  command = "mksquashfs <rootdir> <outputfile>";
  description = "make squashfs image file";
  options = [];

  public async run(rootdir,outputfile) {
    if (process.getuid() !== 0) {
      console.log("You must be a root user.")
      process.exit(-1);
    }

    //else
    child_process.spawnSync("mksquashfs", [rootdir, outputfile, "-noappend", "-comp", "xz", "-no-exports"], {stdio:"inherit"});
  }
}
