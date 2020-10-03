import * as fs from "fs-extra";
import * as path from "path";
import * as child_process from "child_process";
import * as crypto from "crypto";
import {Context} from "./context";


function is_elf(filename:string):boolean
{
  const fd = fs.openSync(filename, "r");
  try {
    const buf = Buffer.alloc(4);
    fs.readSync(fd, buf, 0, 4, null);
    if (buf[0] == 0x7f
      && buf[1] == 'E'.charCodeAt(0)
      && buf[2] == 'L'.charCodeAt(0)
      && buf[3] == 'F'.charCodeAt(0)) return true;
  }
  finally {
    fs.closeSync(fd);
  }
  return false;
}

const cache_dir_name = "./cache/ldd";

function cache_file_name(context:Context, md5hash:string):string
{
  if (!context.ld_so_cache_hash) {
    context.ld_so_cache_hash = crypto.createHash("md5").update(
      fs.readFileSync(path.join(context.srcdir, "etc/ld.so.cache"))
    ).digest("hex");
  }
  return `${cache_dir_name}/${context.ld_so_cache_hash}-${md5hash}`;
}

function get_cache(context:Context, md5hash:string):string[] | null
{
  try {
    return fs.readFileSync(cache_file_name(context, md5hash), "utf-8").split("\n").filter(Boolean);
  }
  catch (failed) {
    return null;
  }
}

function save_cache(context:Context, md5hash:string, deps:string[]):void
{
  fs.ensureDirSync(cache_dir_name);
  const fd = fs.openSync(cache_file_name(context, md5hash), "w");
  try {
    deps.forEach(_ => fs.writeSync(fd, _ + "\n"));
  }
  finally {
    fs.closeSync(fd);
  }
}

function is_executable(filename:string):boolean
{
  try {
    fs.accessSync(filename, fs.constants.X_OK);
    return true;
  }
  catch (err) {
    return false;
  }
}

function get_elf_deps(context:Context,filename:string, no_cache:boolean):string[]
{
  const md5hash = crypto.createHash("md5").update(fs.readFileSync(path.join(context.srcdir, filename))).digest("hex");

  var deps = no_cache? null : get_cache(context, md5hash);

  if (!deps) {
    try {
      deps = child_process.execSync(`chroot ${context.srcdir} ldd ${filename}`,{encoding:"utf-8"}).split("\n")
      .filter(_ => _.indexOf(": no version information available ") < 0)
      .map(_ => _.trim().replace(/\s\(0x[0-9a-f]+\)$/, "").replace(/^.+?\s=>\s/,""))
      .filter(_ => _.indexOf('/') === 0);
    }
    catch (somethingwrong) {
      deps = [];
    }
    if (!no_cache) save_cache(context, md5hash, deps);
  }

  return deps;
}

export function file(context:Context, filename:string, no_elf_cache = false)
{
  if (context.files.has(filename)) return;

  context.files.add(filename);
  const src = path.join(context.srcdir,filename);
  const dst = path.join(context.dstdir,filename);

  const stat = fs.lstatSync(src);

  if (stat.isFile()) {
    if (is_executable(src) && is_elf(src)) {
      get_elf_deps(context, filename, no_elf_cache).forEach(_=>file(context, _, no_elf_cache));
    }
    console.log(`F ${src} -> ${dst}`);
  } else if (stat.isSymbolicLink()) {
    const link = fs.readlinkSync(src);
    file(context,
      link.indexOf('/') === 0? filename : path.join(path.dirname(filename), link),
    no_elf_cache);

    console.log(`L ${src} -> ${dst}(${fs.readlinkSync(src)})`);
    //fs.removeSync(dst);
  } else if (stat.isDirectory()) {
    console.log(`D ${src} -> ${dst}`);
  }
  context.files_queued.push(filename);
}

export function flush(context:Context)
{
  child_process.spawnSync("rsync", ["-a", "--keep-dirlinks", "--files-from=-", context.srcdir + "/", context.dstdir],
    {input:context.files_queued.join('\n'), stdio:[null, "inherit", "inherit"]});
  context.files_queued = [];
}
