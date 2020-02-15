import * as path from "path";
import * as fs from "fs-extra";
import * as glob from "glob";

import {Subcommand} from "./subcommand";
import {Context} from "./collect/context";

export class Artifact2Dep implements Subcommand<[string[]]> {
  command = "artifact2dep [artifact_files...]";
  description = "generate dep file from *.artifact for make";
  options = [
  ];

  public run(artifact_files:string[]) {
    const profiles = new Set<string>();

    artifact_files.forEach( artifact_file => {
      const artifact = path.basename(artifact_file).replace(/\..+?$/, "");
      const settings = JSON.parse(fs.readFileSync(artifact_file, 'utf8'));
      const profile = settings["profile"]; //"gpgpu";
      const main_lstfile = settings["main_lstfile"]; //"components/gpgpu.lst";
      //const all_lstfiles = glob.sync(`${path.dirname(main_lstfile)}/**/*.lst`);
      process.stdout.write(`build/${artifact}/done: $(shell find ${path.dirname(main_lstfile)} -name '*.lst') gentoo/${profile}/done\n`);
      process.stdout.write(`\t$(SUDO) rm -rf build/${artifact}\n`);
      process.stdout.write(`\t$(SUDO) ./do.ts collect gentoo/${profile} build/${artifact} ${main_lstfile}\n`);
      profiles.add(profile);
    });

    profiles.forEach(profile => {
      const profile_depfiles = glob.sync(`profile/${profile}/**`);
      process.stdout.write(`gentoo/${profile}/done: $(shell find profile/${profile})\n`);
      process.stdout.write(`\t./autobuild.sh ${profile}\n\n`);
      process.stdout.write(`${profile}.sources.iso: gentoo/${profile}/done\n`);
      process.stdout.write(`\tmkisofs -J -r -graft-points -o $@ portage=gentoo/${profile}/etc/portage distfiles=gentoo/${profile}/var/cache/distfiles\n`);
    });
  }
}
