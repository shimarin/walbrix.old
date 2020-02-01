import * as fs from "fs-extra";
import * as path from "path";
import * as child_process from "child_process";
import * as commander from "commander";
import {parse as shellparse} from "shell-quote";
import * as rimraf from "rimraf";
import * as glob from "glob";
import {Subcommand} from "../subcommand";
import {Context} from "./context";
import {file,flush} from "./file";
import {process_package} from "./package";
import {exec} from "./exec";
import {get_kernel_version_string} from "../kernelver";
import {download as download_cacheable} from "../download";

class Glob {
  public pattern:string
  constructor(pattern:string) { this.pattern = pattern; }
}

function set(context:Context, envname:string, value:string|Glob)
{
  context.env[envname] = value instanceof Glob? glob.sync(value.pattern, {cwd:context.dstdir,root:context.dstdir,nomount:true}).join(" ") : value;
  console.log(`$${envname} set to ${context.env[envname]}`);
}

function kernel(context:Context, kernelimage:string)
{
  const kernelver = get_kernel_version_string(path.join(context.srcdir, kernelimage));
  set(context, "KERNEL_VERSION", kernelver);
  set(context, "WALBRIX_VERSION", kernelver.split('-', 2)[0]);
}

function dir(context:Context, dirname:string)
{
  dirname = dirname.replace(/\/+$/, "");
  console.log(`Directory: ${dirname}`);
  if (child_process.spawnSync("rsync", ["-ax", "--delete", path.join(context.srcdir, dirname), path.join(context.dstdir, path.dirname(dirname))],
    {stdio:[null, "inherit", "inherit"]}).status !== 0) throw new Error("rsync failed.");
}

function mkdir(context:Context, dirname:string, options?:{owner?:string,mode?:string})
{
  dirname = dirname.replace(/\/+$/, "");
  console.log(`Making directory: ${dirname}`);
  fs.mkdirpSync(path.join(context.dstdir, dirname));
  if (options?.owner) {
    if (child_process.spawnSync("chroot", [context.dstdir, "chown", options.owner, dirname], {stdio:"inherit"}).status !== 0) {
      throw Error(`'chown ${options.owner} ${dirname}' failed`);
    };
  }
  if (options?.mode) {
    if (child_process.spawnSync("chroot", [context.dstdir, "chmod", options.mode, dirname], {stdio:"inherit"}).status !== 0) {
      throw Error(`'chmod ${options.mode} ${dirname}' failed`);
    }
  }
}

function copy(context:Context, srcfile:string, dstfile:string)
{
  let dstfile_full = path.join(context.dstdir, dstfile);
  if (dstfile.endsWith('/')) {
    try {
      if (!fs.statSync(dstfile_full).isDirectory()) {
        console.log("Warning: destination is not a directory");
      }
    }
    catch (e) {
      // no dst dir found
      file(context, dstfile.replace(/\/+$/, ""));
      flush(context);
    }
  }
  try {
    const stat = fs.statSync(dstfile_full);
    if (stat.isDirectory()) {
      dstfile_full = path.join(dstfile_full, path.basename(srcfile));
    }
  }
  catch (e) {
    // pass through
  }
  fs.mkdirsSync(path.dirname(dstfile_full));
  console.log(`$copy ${srcfile} -> ${dstfile_full}`);
  if (child_process.spawnSync("cp", ["-a", srcfile, dstfile_full],
    {stdio:[null, "inherit", "inherit"]}).status === 0) {
    fs.chownSync(dstfile_full, 0, 0);
  }
}

function sed(context:Context, targetfile:string|Glob, expr:string, allow_no_op:boolean)
{
  const files = targetfile instanceof Glob? glob.sync(path.join(context.dstdir, targetfile.pattern)) : [ path.join(context.dstdir, targetfile) ];
  if (files.length == 0) throw Error(`sed: no files such as ${targetfile}`);

  let count = 0;
  files.forEach (_=> {
    if (child_process.spawnSync("sed", ["-i", expr, _], {stdio:[null, "inherit", "inherit"]}).status === 0) {
      count++;
    }
    console.log(`sed -i ${expr} ${_}`);
  });
  if (!allow_no_op && count == 0) throw new Error(`File ${targetfile} not found.`);
}

function write(context:Context, targetfile:string|Glob, content:string, append:boolean = false)
{
  const files = targetfile instanceof Glob? glob.sync(path.join(context.dstdir, targetfile.pattern)) : [ path.join(context.dstdir, targetfile) ];
  if (files.length == 0) throw Error(`write: no files such as ${targetfile}`);

  let count = 0;
  files.forEach (_=> {
    const fd = fs.openSync(_, append? "a":"w");
    try {
      if (child_process.spawnSync("echo", ["-e", content], {stdio:[null, fd, "inherit"]}).status === 0) {
        count ++;
      }
    }
    finally {
      fs.close(fd);
    }
    console.log(`$write to ${_}`);
  });
  if (count == 0) throw new Error("No files were modified.");
}

function symlink(context:Context, pathname:string, target:string, options?:{owner?:string}) {
  const templink = path.join(context.dstdir, `symlink.${process.pid}`);
  fs.symlinkSync(target, templink);
  fs.renameSync(templink, path.join(context.dstdir, pathname));

  if (options?.owner) {
    if (child_process.spawnSync("chroot", [context.dstdir, "chown", options.owner, pathname], {stdio:"inherit"}).status !== 0) {
      throw Error(`'chown ${options.owner} ${pathname}' failed`);
    };
  }
}

function touch(context:Context, filename:string)
{
  fs.writeFileSync(path.join(context.dstdir, filename), "",  {flag:"a"});
}

function del(context:Context, files:string[], force:boolean = false) {
  files.forEach( file => {
    try {
      fs.unlinkSync(path.join(context.dstdir, file));
    }
    catch (e) {
      if (!force) throw e;
    }
  });
}

function deltree(context:Context, dir:string, force:boolean = false) {
  const full_dirname = path.join(context.dstdir, dir);
  try {
    if (!fs.statSync(full_dirname).isDirectory() && !force) {
      throw new Error(`${dir} is not a directory`);
    }
    rimraf.sync(full_dirname);
  }
  catch (e) {
    if (!force) throw e;
  }
}

function cleanup(context:Context, dir:string) {
  const full_dirname = path.join(context.dstdir, dir);
  if (!fs.statSync(full_dirname).isDirectory()) {
    throw new Error(`${dir} is not a directory`);
  }
  rimraf.sync(path.join(full_dirname, '*'));
}

function download(context:Context, url:string, saveto?:string) {
  if (!saveto) saveto = "";
  let full_saveto = path.join(context.dstdir, saveto? saveto : "");
  try {
    if (fs.statSync(full_saveto).isDirectory()) {
      full_saveto = path.join(full_saveto, url.replace(/.+\//, ""));
    }
  }
  catch (e) {
    if (full_saveto.endsWith("/")) throw e;
  }

  const download_cache = download_cacheable(url);
  // else
  fs.copyFileSync(download_cache, full_saveto);
}

function create_command_parser(context:Context, current_dir:string)
{
  const program = new commander.Command();
  program.command("$file <filename>").option("-n --no-elf-cache", "don't use elf dependency cache")
  .action((filename, options:commander.Command)=>{
    file(context, filename, !options.elfCache);
  });
  program.command("$require <lstfile>").action((new_lstfile)=> {
    process_lstfile(context, path.join(current_dir, new_lstfile));
  });
  program.command("$package <pkgname>")
  .option("-u --use <use>", "mandatory use flag")
  .option("-n --no-elf-cache", "don't use elf dependency cache")
  .option("-x --exclude <pattern>", "pattern to exclude files")
  .action((pkgname, options:commander.Command)=>{
    process_package(context, pkgname, {use:options.use, no_elf_cache:!options.elfCache, exclude:options.exclude});
  });
  program.command("$kernel <kernelimage>").action((kernelimage) => {
    kernel(context, kernelimage);
  });
  program.command("$set <envname> <value>").action((envname, value) => {
    set(context, envname, value);
  });
  program.command("$dir <dirname>").action((dirname) => {
    flush(context);
    dir(context, dirname);
  });
  program.command("$mkdir <dirname>").option("-o --owner <owner>").option("-m --mode <mode>")
  .action((dirname, options:commander.Command) => {
    flush(context);
    mkdir(context, dirname, {owner:options.owner, mode:options.mode});
  });
  program.command("$copy <srcfile> <dstfile>").action((srcfile,dstfile) => {
    flush(context);
    copy(context, srcfile, dstfile)
  });
  program.command("$sed <targetfile|glob> <expr>").option("-n --allow-no-op", "allow not to modify any files")
    .action((targetfile,expr, options:commander.Command) => {
    flush(context);
    sed(context, targetfile, expr, options.allowNoOp);
  });
  program.command("$write <filename|glob> <content>").option("-a --append", "append mode").action((filename, content, options:commander.Command) => {
    flush(context);
    write(context, filename, content, options.append);
  });
  program.command("$symlink <path> <target>").option("-o --owner <owner>").action((path, target, options:commander.Command) => {
    flush(context);
    symlink(context, path, target, {owner:options.owner});
  });
  program.command("$touch <path>").action((path)=> {
    flush(context);
    touch(context, path);
  });
  program.command("$exec <command>").option("-o --overlay", "setup overlay before execution")
  .option("-l --ldconfig", "do ldconfig before execution")
  .option("-c --cache <cachename>", "sync specified cache to /var/cache")
  .option("--no-shm", "disable mounting /dev/shm")
  .option("--no-pts", "disable mounting /dev/pts")
  .option("--no-proc", "disable mounting /proc")
  .action((command, options:commander.Command)=> {
    flush(context);
    exec(context, command, {overlay:options.overlay, ldconfig:options.ldconfig, cache:options.cache, no_proc:!options.proc, no_shm:!options.shm, no_pts:!options.pts});
  });
  program.command("$del [files...]").option("-f --force", "ignore errors").action((files, options:commander.Command) => {
    flush(context);
    del(context, files, options.force);
  });
  program.command("$deltree <dir>").option("-f --force", "ignore errors").action((dir, options:commander.Command) => {
    flush(context);
    deltree(context, dir, options.force);
  });
  program.command("$cleanup <dir>").action((dir) => {
    flush(context);
    cleanup(context, dir);
  });
  program.command("$download <url> [saveto]").action((url, saveto?)=> {
    flush(context);
    download(context, url, saveto);
  })
  program.command("*").action((options:commander.Command) => {
    throw new Error("Unknown command.");
  })
  // TODO: raise error for unknown command

  return program;
}

function process_lstfile(context:Context, lstfile:string)
{
  if (context.lstfiles.has(lstfile)) return;
  //else
  context.lstfiles.add(lstfile);
  console.log(`Processing ${lstfile}...`);

  fs.readFileSync(lstfile, "utf-8").split("\n").filter(Boolean).forEach((line)=> {
    const argv:any[] = shellparse(line.indexOf('$') === 0? "\\" + line : line, context.env)
    .map((_:any) => _.op === 'glob'? new Glob(_.pattern) : _)
    .filter(_ => _ instanceof Glob || typeof _ == "string");
//    .map(_ => _.toString());
    if (argv.length > 0) {
      if (argv[0].indexOf('$') !== 0) argv.unshift("$file");
      argv.unshift("ts-node");
      argv.unshift("collect");
      create_command_parser(context, path.dirname(lstfile)).parse(argv);
    }
  });

  console.log(`${lstfile} done.`);
}

export class Collect implements Subcommand<[string,string,string,commander.Command]> {
  command = "collect <srcdir> <dstdir> <lstfile>";
  description = "collect files";
  options = [];

  public run(srcdir:string,dstdir:string,lstfile:string,options:commander.Command) {
    if (process.getuid() !== 0) {
      console.log("You must be a root user.")
      process.exit(-1);
    }
    //else
    fs.ensureDirSync(dstdir);
    const context = new Context(srcdir,dstdir);
    context.env["ARCH"] = "x86_64";
    process_lstfile(context, lstfile);
    flush(context);
  }
}
