import {spawnSync} from "child_process";
import {copySync} from "fs-extra";
import {join} from "path";
import {Subcommand} from "./subcommand";
import {GRUB_MODULES} from "./mkbootimage";

const ADDITIONAL_GRUB_MODULES = [
  "ls"
]

export class GrubInstall implements Subcommand<[string,string,string]> {
  command = "grub-install <bootdir> <device> <grubcfg>";
  description = "install grub for bios";
  options = [];

  public async run(bootdir, device, grubcfg) {
    if (process.getuid() !== 0) {
      console.log("You must be a root user.")
      process.exit(-1);
    }

    //else
    spawnSync("grub-install", ["--target=i386-pc", "--recheck", `--boot-directory=${bootdir}`,
      `--modules=${GRUB_MODULES.concat(ADDITIONAL_GRUB_MODULES).join(' ')}`, device], {stdio:"inherit"});

    copySync(grubcfg, join(bootdir, "grub/grub.cfg"));
  }
}
