#!/usr/bin/env ts-node
import * as path from "path";
import * as program from "commander";
import {DetermineLatestStage3} from "./lib/determine-latest-stage3";
import {Chroot} from "./lib/chroot";
import {Collect} from "./lib/collect/index";
import {KernelVer} from "./lib/kernelver";
import {MkBootImage} from "./lib/mkbootimage";
import {MkSquashFS} from "./lib/mksquashfs";
import {GenKernel} from "./lib/genkernel";
import {GrubInstall} from "./lib/grub-install";

program.name(path.basename(__filename));
program.version("0.0.1");

[
  DetermineLatestStage3,
  Chroot,
  Collect,
  KernelVer,
  MkBootImage,
  MkSquashFS,
  GenKernel,
  GrubInstall
].forEach(_ => {
  const subcommand = new _();
  const command = program.command(subcommand.command)
  .description(subcommand.description)
  .action(subcommand.run);

  subcommand.options.forEach(_ => {
    command.option(_[0], _[1]);
  });
});

if (!process.argv.slice(2).length) {
  program.outputHelp();
  process.exit(1);
}

program.parse(process.argv);
