import { parse } from "https://deno.land/std/flags/mod.ts";
import * as path from "https://deno.land/std/path/mod.ts";
import { Sha1 } from "https://deno.land/std/hash/sha1.ts";
import { ensureDirSync } from "https://deno.land/std/fs/ensure_dir.ts";
import { emptyDirSync } from "https://deno.land/std/fs/empty_dir.ts";
import {existsSync} from "https://deno.land/std/fs/exists.ts";
import {walkSync} from "https://deno.land/std/fs/walk.ts";
//import * as os from "https://deno.land/std/node/os.ts";

import * as runExclusive from "https://deno.land/x/run_exclusive/mod.ts";

const exclusives = runExclusive.createGroupRef();
const utf8decoder = new TextDecoder('utf-8');
const utf8encoder = new TextEncoder();

class Context {
  readonly srcdir:string;
  readonly dstdir:string;
  public files = new Set<string>();
  public packages = new Set<string>();
  public env:any = {};

  public files_queued:string[] = [];
  public ld_so_cache_hash?: string;

  constructor(srcdir:string,dstdir:string) {
    this.srcdir = srcdir;
    this.dstdir = dstdir;
  }
}

var context:Context;

function is_elf(_path:string)
{
  const fd = Deno.openSync(_path, {read:true});
  try {
    const buf = new Uint8Array(4);
    fd.readSync(buf);
    if (buf[0] == 0x7f
      && buf[1] == 'E'.charCodeAt(0)
      && buf[2] == 'L'.charCodeAt(0)
      && buf[3] == 'F'.charCodeAt(0)) return true;
  }
  finally {
    fd.close();
  }
  return false;
}

const cache_dir_name = "./cache/ldd";

function cache_file_name(sha1hash:string):string
{
  if (!context.ld_so_cache_hash) {
    context.ld_so_cache_hash = new Sha1().update(
      Deno.readFileSync(path.join(context.srcdir, "etc/ld.so.cache"))
    ).hex();
  }
  return path.join(cache_dir_name, context.ld_so_cache_hash, sha1hash);
}

function get_elf_cache(sha1hash:string):string[] | null
{
  try {
    return utf8decoder.decode(Deno.readFileSync(cache_file_name(sha1hash))).split("\n").filter(Boolean);
  }
  catch (failed) {
    return null;
  }
}

function save_elf_cache(sha1hash:string,deps:string[])
{
  const _cache_file_name = cache_file_name(sha1hash);
  ensureDirSync(path.dirname(_cache_file_name));
  const fd = Deno.openSync(cache_file_name(sha1hash), {write:true,create:true});
  try {
    deps.forEach(_ => fd.writeSync(utf8encoder.encode(_ + "\n")));
  }
  finally {
    fd.close();
  }
}

async function get_elf_deps(_path:string)
{
  const sha1hash = new Sha1().update(Deno.readFileSync(path.join(context.srcdir, _path))).hex();
  const elf_cache = get_elf_cache(sha1hash);
  if (elf_cache) {
    //console.log("CACHE HIT");
    return elf_cache;
  }

  //else
  const p1 = Deno.run({cmd:["scanelf", "--root=" + context.srcdir, "-qLF", "#F%n", _path],stdout:"piped"});
  const p2 = Deno.run({cmd:["scanelf", "--root=" + context.srcdir, "-qF", "#F%r", _path],stdout:"piped"});
  const status1 = await p1.status();
  const status2 = await p2.status();
  console.log(status1, status2);
  if (status1.success && status2.success) {
    const p1_output = utf8decoder.decode(await p1.output()).trim();
    const p2_output = utf8decoder.decode(await p2.output()).trim();
    const rpath = p2_output.split(":").map(_=>_ == "$ORIGIN" ? path.dirname(_path) : _);
    const deps = p1_output == ""? [] : p1_output.split(",").map(_=> {
      if (_[0] == '/') return _;
      //else
      for (let rp of rpath) {
        if (existsSync(path.join(context.srcdir, rp, _))) return path.join(rp, _);
      }
      if (existsSync(path.join(path.dirname(_path), _))) return path.join(path.dirname(_path), _);
      //else
      throw new Error(`Shared library ${_} referred by ${_path} couldn't be found.  rpath=${rpath}`);
    });
    p1.close();
    p2.close();
    save_elf_cache(sha1hash, deps);
    return deps;
  }
  //else
  p1.close();
  p2.close();
  save_elf_cache(sha1hash, []);
  return [];
}

async function process_single_file(_path:string)
{
  if (context.files.has(_path)) return;

  //else
  context.files.add(_path);
  const src = path.join(context.srcdir,_path);
  const dst = path.join(context.dstdir,_path);
  const stat = (()=>{try {
    return Deno.lstatSync(src)
  }
  catch(e) {
    throw new Error("Cannot stat " + src)
  }})();
  if (stat.isFile) {
    if (is_elf(src)) {
      for (let _ of await get_elf_deps(_path)) {
        await process_single_file(_);
      }
    }
    console.log(`F ${src} -> ${dst}`);
  } else if (stat.isSymlink) {
    const link = Deno.readLinkSync(src);
    await process_single_file(link.indexOf('/') === 0? _path : path.join(path.dirname(_path), link));
    console.log(`L ${src} -> ${dst}(${Deno.readLinkSync(src)})`);
  } else if (stat.isDirectory) {
    console.log(`D ${src} -> ${dst}`);
  }
  context.files_queued.push(_path);
  if (context.files_queued.length > 256) await flush();
}

async function flush()
{
  if (context.files_queued.length == 0) return;
  //else

  //console.log(context.files_queued.join('\n'));

  const p = Deno.run({cmd:["rsync", "-a", "--keep-dirlinks", "--files-from=-", context.srcdir + "/", context.dstdir], stdin:"piped"});
  if (p.stdin) {
    await p.stdin.write(utf8encoder.encode(context.files_queued.join('\n')));
    p.stdin.close();
  }
  context.files_queued = [];
  const status = await p.status();
  p.close();
  if (!status.success) throw new Error("rsync failed");
}

export const f = runExclusive.build(exclusives,
  async (...args:string[]) => {
    for (let _ of args) await process_single_file(_);
    await flush();
  }
)

function find_package(pkgname:string|RegExp)
{
  const root = path.join(context.srcdir, "var/db/pkg");
  return Array.from(walkSync(root, {maxDepth:2,includeFiles:false})).map ( _ => {
    const splitted = _.path.substring(root.length + 1).split("/");
	  if (splitted.length < 2) return { category:splitted[0] }
    //else
    const category = splitted[0];
    const name_and_version = splitted[1];
    const name = name_and_version.replace(/-r\d+$/, "").replace(/-[^-]+$/, "");
    return {
      full: category + "/" + name_and_version,
		  category: category,
      name_and_version: name_and_version,
      name: name,
      get_use_flags: () =>
        utf8decoder.decode(Deno.readFileSync(path.join(root, category, name_and_version, "USE"))).replace(/(\r\n|\n|\r)/gm, "").split(" "),
      get_contents: () =>
        utf8decoder.decode(Deno.readFileSync(path.join(root, category, name_and_version, "CONTENTS"))).split("\n").filter(_=>
          _.indexOf("obj ") === 0 || _.indexOf("sym ") === 0 || _.indexOf("dir ") === 0
        ).map(_=>
          _.replace(/^(obj\s.+)\s[0-9a-z]+\s\d+$/, "$1")
          .replace(/^(sym\s.+)\s->\s.+$/, "$1")
          .replace(/^.+?\s(.+)$/, "$1")
        )
	  }
  }).filter ( _ => {
	  if (!_.name) return false;
    //else
    if (typeof pkgname == "string") {
      return (pkgname == _.full)
  		  || (pkgname == _.category + "/" + _.name)
  	    || (pkgname == _.name_and_version)
  		  || (pkgname == _.name);
    } else if (pkgname instanceof RegExp) {
      return _.full.match(pkgname);
    }
  });
}

export const pkg = runExclusive.build(exclusives,
  async (pkgname:string|RegExp,options:{use?:string[]|string,nocopy?:boolean,exclude?:string|RegExp}={}) => {

    const matched = find_package(pkgname);

    if (matched.length == 0) {
      throw new Error(`No packages such as "${pkgname}" found.`);
    }

    if (matched.length > 1) {
      throw new Error(`Package specification "${pkgname}" is ambigious. Candidates:\n` + matched.map(_ => _.full).join("\n"));
    }

    const pkg = matched[0];

    if (!pkg.full) throw new Error("something wrong");

    if (context.packages.has(pkg.full)) return; // already collected

    // else
    console.log(`pkg ${pkg.full}`);
    const use = options.use? (Array.isArray(options.use)? options.use : [options.use]) : null;
    const use_flags = pkg.get_use_flags();
    if (use && use.some(_ => _.startsWith('-')? use_flags.includes(_.replace(/^-/,"")) : !use_flags.includes(_))) {
      throw new Error(`Package "${pkg.full}" does not satisfy use flag condition "${use.join(" ")}"`);
    }

    context.packages.add(pkg.name);

    if (options?.nocopy) return; // just make sure package is installed

    const excluded_prefixes = [
      "/run",
      "/usr/share/man",
      "/usr/share/doc",
      "/usr/share/info",
      "/usr/include"
    ];

    const included_locales = [
      "ja"
    ]

    for (let filename of pkg.get_contents()) {
      if (!excluded_prefixes.some(_ =>  _ === filename || filename.startsWith(_ + '/') )
        && (!filename.startsWith("/usr/share/locale/") || included_locales.some( _ => filename.startsWith("/usr/share/locale/" + _ + '/')))
        && (!options.exclude || !filename.match(options.exclude))) {
        await process_single_file(filename);
      }
    }

    await flush();
  }
)

function getbyte(fd:Deno.File):[boolean,number|null]
{
  const buf = new Uint8Array(1);
  const read = fd.readSync(buf);
  if (!read || read < 1) return [false, null];
  //else
  return [true, buf[0]];
}

export const kernel = runExclusive.build(exclusives,
  async(_path:string) => {
    const kernel_image = path.join(context.srcdir, _path);

    const fd = Deno.openSync(kernel_image, {read:true});
    try {
      if (fd.seekSync(526, Deno.SeekMode.Start) != 526) throw new Error(`Invalid kernel image: ${path}`);
      const buf = new Uint8Array(2);
      const read = fd.readSync(buf);
      if (!read || read < 2) throw new Error(`Invalid kernel image: ${path}`);

      const head = buf[0] + buf[1] * 256 + 0x200;
      if (fd.seekSync(head, Deno.SeekMode.Start) != head) throw new Error(`Invalid kernel image: ${path}`);

      var kernelver = "";
      var r = getbyte(fd);
      while (r[0] && r[1] && r[1] > 0 && r[1] != 0x20/*space*/) {
        kernelver += String.fromCharCode(r[1]);
        r = getbyte(fd);
      }
      context.env["KERNEL_VERSION"] = kernelver;
      console.log(`KERNEL_VERSION set to ${kernelver}`);
      return kernelver;
    }
    finally {
      fd.close();
    }
  }
);

export const dir = runExclusive.build(exclusives,
  async(_path:string) => {
    const dirname = _path.replace(/\/+$/, "");
    console.log(`Directory: ${dirname}`);

    const status = await Deno.run({cmd:["rsync", "-ax", "--delete", path.join(context.srcdir, dirname), path.join(context.dstdir, path.dirname(dirname))]}).status();

    if (!status.success) {
      throw new Error(`Error copying directory ${dirname}`);
    }

  }
);

export const write = runExclusive.build(exclusives,
  async(_path:string, content:string, options:{append:boolean}={append:false}) => {
    const actual_path = path.join(context.dstdir, _path);
    if (!existsSync(path.dirname(actual_path))) {
      throw new Error(`Directory ${path.dirname(_path)} does not exist.`);
    }
    Deno.writeFileSync(actual_path, utf8encoder.encode(content), {append:options.append});
  }
);

export const sed = runExclusive.build(exclusives,
  async(_path:string, expr:string) => {
    const status = await Deno.run({cmd:["sed", "-i", expr, path.join(context.dstdir, _path)]}).status();
    if (status.success) {
      console.log(`sed -i ${expr} ${_path}`);
    } else {
      throw new Error(`sed failed while applying ${expr} to ${_path}`);
    }
  }
);

export const mkdir = runExclusive.build(exclusives,
  async(_path:string,options:{mode?:number}={}) => {
    const dir_to_make = path.join(context.dstdir, _path);
    ensureDirSync(dir_to_make);
    if (options.mode) {
      Deno.chmodSync(dir_to_make, options.mode)
    }
    console.log(`mkdir: ${_path}`);
  }
);

export const copy = runExclusive.build(exclusives,
  async(src:string, dst:string) => {
    let dst_full = path.join(context.dstdir, dst);
    if (dst.endsWith('/')) {
     try {
       if (!Deno.statSync(dst_full).isDirectory) {
         console.log("Warning: destination is not a directory");
       }
     }
     catch (e) {
       // no dst dir found
       process_single_file(dst.replace(/\/+$/, ""));
       flush();
     }
    }
    try {
     const stat = Deno.statSync(dst_full);
     if (stat.isDirectory) {
       dst_full = path.join(dst_full, path.basename(src));
     }
    }
    catch (e) {
     // pass through
    }
    ensureDirSync(path.dirname(dst_full));
    console.log(`copy ${src} -> ${dst_full}`);
    const status = await Deno.run({cmd:["cp", "-a", src, dst_full]}).status();
    if (status.success) {
      await Deno.run({cmd:["chown", "-R", "root.root", dst_full]}).status();
    } else {
      throw new Error(`Failed to copy ${src} to ${dst_full}`);
    }
  }
);

export const touch = runExclusive.build(exclusives,
  async(_path:string) => {
    console.log(`touch: ${_path}`);
    Deno.openSync(path.join(context.dstdir, _path), {write:true,create:true}).close();
  }
);

export const symlink = runExclusive.build(exclusives,
  async(_path:string, target:string, options:{owner?:number,group?:number}={})=> {
    const templink = path.join(context.dstdir, `symlink.${Deno.pid}`);
    const status = await Deno.run({cmd:["ln", "-sf", target, templink]}).status();
    if (!status.success) throw new Error(`Failed to create symlink ${templink}`);
    //Deno.symlinkSync(target, templink);
    const finallink = path.join(context.dstdir, _path);
    Deno.renameSync(templink, finallink);

    if (options.owner !== undefined || options.group !== undefined) {
      const owner = options?.owner || 0;
      const group = options?.group || 0;
      Deno.chownSync(finallink, owner, group);
    }

    console.log(`symlink: ${_path} => ${target}`);
  }
);

export const exec = runExclusive.build(exclusives,
  async(cmd:string|string[], options:{overlay:boolean} = {overlay:false}) => {
    const dst_abs = Deno.realPathSync(context.dstdir);
    const actual_cmd = Array.isArray(cmd)? cmd : ["sh", "-c", cmd];
    const status = options.overlay?
      (await Deno.run({cmd:["systemd-nspawn", "-D", context.srcdir, `--overlay=+/:${dst_abs}:/`].concat(actual_cmd),env:{SYSTEMD_NSPAWN_TMPFS_TMP:"0"}}).status())
      :
      (await Deno.run({cmd:["systemd-nspawn", "-D", context.dstdir].concat(actual_cmd),env:{SYSTEMD_NSPAWN_TMPFS_TMP:"0"}}).status())
    if (!status.success) throw new Error(`Error executing command ${cmd}. overlay=${options.overlay}`);
  }
);

//const userInfo = os.userInfo()

const args = parse(Deno.args);

context = new Context(args._[0].toString(), args._[1].toString());

emptyDirSync(context.dstdir);

const p = await Deno.run({cmd:["file", "-L", path.join(context.srcdir, "/bin/sh")],stdout:"piped"})

if (utf8decoder.decode(await p.output()).includes("80386")) {
  context.env["ARCH"] = "i686";
  context.env["LIB"] = "lib";
} else {
  context.env["ARCH"] = "x86_64";
  context.env["LIB"] = "lib64";
}
p.close();

export const env = context.env;

if (import.meta.main) {
  console.log("main");
}
