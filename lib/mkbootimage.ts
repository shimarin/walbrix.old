import * as child_process from "child_process";
import * as path from "path";
import * as fs from "fs-extra";
import {Subcommand} from "./subcommand";

export const GRUB_MODULES = [
  "xfs","fat","part_gpt","part_msdos","normal","linux","echo","all_video",
  "test","multiboot","multiboot2","search","sleep","iso9660","gzio","lvm","chain",
  "configfile","cpuid","minicmd","gfxterm","font","terminal","squash4",
  "loopback","videoinfo","videotest","blocklist","probe"
];

const BOOTLOADER_SIZE = 1024 * 1024;

export class MkBootImage implements Subcommand<[string,string,string]> {
  command = "mkbootimage <sourcedir> <cfgfile> <outputfile>";
  description = "make boot image file";
  options = [];

  public async run(sourcedir,cfgfile,outputfile) {
    if (process.getuid() !== 0) {
      console.log("You must be a root user.")
      process.exit(-1);
    }

    //else
    fs.copySync(cfgfile, path.join(sourcedir, "tmp/grub.cfg"))
    child_process.spawnSync("chroot", [sourcedir, "grub-mkimage", "-p", "/boot/grub", "-c", "/tmp/grub.cfg", "-o", "/tmp/bootx64.efi", "-O", "x86_64-efi"].concat(GRUB_MODULES), {stdio:"inherit"});
    const bootloader_src = path.join(sourcedir, "tmp/bootx64.efi");
    const stat = fs.statSync(bootloader_src);
    if (stat.size > BOOTLOADER_SIZE) {
      console.log(`Bootloader(${stat.size}) is larger than its limit(${BOOTLOADER_SIZE}) `);
      process.exit(-1)
    }
    // else
    const buf = fs.readFileSync(bootloader_src);
    const fd = fs.openSync(outputfile, "w");
    try {
      fs.writeSync(fd, buf, 0, stat.size, null);
      const pad = Buffer.alloc(BOOTLOADER_SIZE - stat.size);
      fs.writeSync(fd, pad, 0, pad.byteLength, null);
    }
    finally {
      fs.closeSync(fd);
    }

  }
}
