import * as path from "path";
import * as fs from "fs-extra";
import {Subcommand} from "./subcommand";

export class Artifact2Dep implements Subcommand<[string[]]> {
  command = "artifact2dep [artifact_files...]";
  description = "generate dep file from *.artifact for make";
  options = [
  ];

  public run(artifact_files:string[]) {
    //fs.copyFileSync(artifact_file, dep_file);
    artifact_files.forEach( artifact_file => {
      const artifact = path.basename(artifact_file).replace(/\..+?$/, "");
      const settings = JSON.parse(fs.readFileSync(artifact_file, 'utf8'));
      const profile = settings["profile"]; //"gpgpu";
      const main_lstfile = settings["main_lstfile"]; //"components/gpgpu.lst";
      process.stdout.write(`build/${artifact}/done: ${main_lstfile} gentoo/${profile}/done\n`);
      process.stdout.write(`\t$(SUDO) rm -rf $(patsubst build/%/done,build/%,$@)\n`);
      process.stdout.write(`\t$(SUDO) ./do.ts collect gentoo/${profile} $(patsubst build/%/done,build/%,$@) ${main_lstfile}\n`);
    });
  }
}
