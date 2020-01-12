import * as fs from "fs-extra";
import * as path from "path";
import * as child_process from "child_process";
import * as commander from "commander";
import {parse as shellparse} from "shell-quote";
import * as glob from "glob";
import {Subcommand} from "../subcommand";
import {Context} from "./context";
import {file,flush} from "./file";
import {get_kernel_version_string} from "../kernelver";

function process_package(context:Context, pkgname:string)
{
  const category_and_name = pkgname.split('/', 2);
  const category = category_and_name.length > 1? category_and_name.shift() : "*";
  const name = category_and_name[0];

  const matched = glob.sync(path.join(context.srcdir, `var/db/pkg/${category}/${name}-*/CONTENTS`)).map (_=> {
    const category = fs.readFileSync(path.join(path.dirname(_), "CATEGORY")).toString().trim();
    const pf = fs.readFileSync(path.join(path.dirname(_), "PF"), "utf-8").trim();
    return {
      name: `${category}/${pf}`,
      contents: fs.readFileSync(_, "utf-8").split("\n")
      .filter( _ => _.indexOf("obj ") === 0 || _.indexOf("sym ") === 0 || _.indexOf("dir ") === 0)
      .map(_ => _.split(' ', 2)[1])
    }
  });

  if (matched.length == 0) {
    console.log(`No packages such as "${pkgname}" found.`);
    process.exit(-1);
  }

  if (matched.length > 1) {
    console.log(`Package specification "${pkgname}" is ambigious. Candidates:`);
    matched.forEach(_ => {
      console.log(`${_.name}`);
    });
    process.exit(-1);
  }

  const pkg = matched[0];

  if (context.packages.has(pkg.name)) return; // already collected

  // else
  console.log(`package ${pkg.name}`);
  context.packages.add(pkg.name);

  const excluded_prefixes = [
    "/usr/share/man",
    "/usr/share/doc",
    "/usr/share/info",
    "/usr/include"
  ];

  const included_locales = [
    "ja"
  ]

  pkg.contents.forEach(filename => {
    if (!excluded_prefixes.some(_ =>  _ === filename || filename.startsWith(_ + '/') )
      && (!filename.startsWith("/usr/share/locale/") || included_locales.some( _ => filename.startsWith("/usr/share/locale/" + _ + '/')))) {
      file(context, filename);
    }
  });
}

function kernel(context:Context, kernelimage:string)
{
  const kernelver = get_kernel_version_string(path.join(context.srcdir, kernelimage));
  context.env["KERNEL_VERSION"] = kernelver;
  context.env["WALBRIX_VERSION"] = kernelver.split('-', 2)[0];
  console.log(`$KERNEL_VERSION set to ${kernelver}`);
}

function dir(context:Context, dirname:string)
{
  dirname = dirname.replace(/\/+$/, "");
  console.log(`Directory: ${dirname}`);
  child_process.spawnSync("rsync", ["-ax", "--delete", path.join(context.srcdir, dirname), path.join(context.dstdir, path.dirname(dirname))],
    {stdio:[null, "inherit", "inherit"]});
}

function mkdir(context:Context, dirname:string)
{
  dirname = dirname.replace(/\/+$/, "");
  console.log(`Making directory: ${dirname}`);
  fs.mkdirpSync(path.join(context.dstdir, dirname));
}

function copy(context:Context, srcfile:string, dstfile:string)
{
  if (dstfile.endsWith('/')) {
    file(context, dstfile.replace(/\/+$/, ""));
    flush(context);
  }
  let dstfile_full = path.join(context.dstdir, dstfile);
  if (fs.statSync(dstfile_full).isDirectory()) {
    dstfile_full = path.join(dstfile_full, path.basename(srcfile));
  }
  fs.mkdirsSync(path.dirname(dstfile_full));
  console.log(`$copy ${srcfile} -> ${dstfile_full}`);
  if (child_process.spawnSync("cp", ["-a", srcfile, dstfile_full],
    {stdio:[null, "inherit", "inherit"]}).status === 0) {
    fs.chownSync(dstfile_full, 0, 0);
  }
}

function sed(context:Context, targetfile:string, expr:string)
{
  const targetfile_full = path.join(context.dstdir, targetfile);
  child_process.spawnSync("sed", ["-i", expr, targetfile_full], {stdio:[null, "inherit", "inherit"]});
  console.log(`sed -i ${expr} ${targetfile_full}`);
}

function write(context:Context, filename:string, content:string)
{
  const filename_full = path.join(context.dstdir, filename);
  console.log(`$write to ${filename_full}`);

  const fd = fs.openSync(filename_full, "w");
  try {
    child_process.spawnSync("echo", ["-e", content], {stdio:[null, fd, "inherit"]});
  }
  finally {
    fs.close(fd);
  }
}

function symlink(context:Context, pathname:string, target:string) {
  const templink = path.join(context.dstdir, `symlink.${process.pid}`);
  fs.symlinkSync(target, templink);
  fs.renameSync(templink, path.join(context.dstdir, pathname));
}

function touch(context:Context, filename:string)
{
  fs.writeFileSync(path.join(context.dstdir, filename), "",  {flag:"a"});
}

function process_lstfile(context:Context, lstfile:string)
{
  if (context.lstfiles.has(lstfile)) return;
  //else
  context.lstfiles.add(lstfile);
  console.log(`Processing ${lstfile}...`);
  const program = new commander.Command();
  program.command("$file <filename>").action((filename)=>{
    file(context, filename);
  });
  program.command("$require <lstfile>").action((new_lstfile)=> {
    process_lstfile(context, path.join(path.dirname(lstfile), new_lstfile));
  });
  program.command("$package <pkgname>").action((pkgname)=>{
    process_package(context, pkgname);
  });
  program.command("$kernel <kernelimage>").action((kernelimage) => {
    kernel(context, kernelimage);
  });
  program.command("$dir <dirname>").action((dirname) => {
    flush(context);
    dir(context, dirname);
  });
  program.command("$mkdir <dirname>").action((dirname) => {
    flush(context);
    mkdir(context, dirname);
  });
  program.command("$copy <srcfile> <dstfile>").action((srcfile,dstfile) => {
    flush(context);
    copy(context, srcfile, dstfile)
  });
  program.command("$sed <targetfile> <expr>").action((targetfile,expr) => {
    flush(context);
    sed(context, targetfile, expr);
  })
  program.command("$write <filename> <content>").action((filename, content) => {
    flush(context);
    write(context, filename, content);
  })
  program.command("$symlink <path> <target>").action((path, target) => {
    flush(context);
    symlink(context, path, target);
  })
  program.command("$touch <path>").action((path)=> {
    flush(context);
    touch(context, path);
  })
  // TODO: raise error for unknown command

  fs.readFileSync(lstfile, "utf-8").split("\n").filter(Boolean).forEach((line)=> {
    const argv:string[] = shellparse(line.indexOf('$') === 0? "\\" + line : line, context.env)
    .filter(_ => typeof _ == "string")
    .map(_ => _.toString());
    if (argv.length > 0) {
      if (argv[0].indexOf('$') !== 0) argv.unshift("$file");
      argv.unshift("ts-node");
      argv.unshift("collect");
      program.parse(argv);
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
