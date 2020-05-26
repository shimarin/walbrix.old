import { parse } from "https://deno.land/std/flags/mod.ts";
import * as path from "https://deno.land/std/path/mod.ts";
import { Sha1 } from "https://deno.land/std/hash/sha1.ts";
import { ensureDirSync } from "https://deno.land/std/fs/ensure_dir.ts";
import { emptyDirSync } from "https://deno.land/std/fs/empty_dir.ts";
import {existsSync} from "https://deno.land/std/fs/exists.ts";
import {walkSync} from "https://deno.land/std/fs/walk.ts";
//import * as os from "https://deno.land/std/node/os.ts";

import * as shell_escape from 'https://deno.land/x/shell_escape/index.ts';
import * as runExclusive from "https://deno.land/x/run_exclusive/mod.ts";

class Context {
  readonly utf8decoder = new TextDecoder('utf-8');
  readonly utf8encoder = new TextEncoder();

  readonly srcdir:string;
  readonly outfile:Deno.File;
  public files = new Set<string>();
  public packages = new Set<string>();
  public elf_deps = new Map<string,string[]>();

  constructor(srcdir:string,outfile:string) {
    this.srcdir = srcdir;
    this.outfile = Deno.openSync(outfile, {read:true,write:true,create:true,truncate:true});
  }

  public writeSync(content:string):number {
    return this.outfile.writeSync(this.utf8encoder.encode(content));
  }

  public writeSyncLn(content:string):number {
    return this.writeSync(content + '\n');
  }
}

var context:Context;

function process_single_file(_path:string)
{
  if (context.files.has(_path)) return;

  //else
  context.files.add(_path);
  const src = path.join(context.srcdir,_path);
  const stat = Deno.lstatSync(src);

  if (stat.isFile) {
    if (context.elf_deps.has(_path)) {
      context.elf_deps.get(_path)?.forEach(_ => process_single_file(_));
    }
    console.log(`F ${src}`);
  } else if (stat.isSymlink) {
    const link = Deno.readLinkSync(src);
    process_single_file(link.indexOf('/') === 0? _path : path.join(path.dirname(_path), link));
    console.log(`L ${src} -> ${Deno.readLinkSync(src)}`);
  } else if (stat.isDirectory) {
    console.log(`D ${src}`);
  }

  context.writeSyncLn(`touch -ach ${shell_escape.singleArgument(_path)}`);
}

export function f(...args:string[]) {
  for (let _ of args) process_single_file(_);
}

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
        context.utf8decoder.decode(Deno.readFileSync(path.join(root, category, name_and_version, "USE"))).replace(/(\r\n|\n|\r)/gm, "").split(" "),
      get_contents: () =>
        context.utf8decoder.decode(Deno.readFileSync(path.join(root, category, name_and_version, "CONTENTS"))).split("\n").filter(_=>
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

export function pkg(pkgname:string|RegExp,options:{use?:string[]|string,nocopy?:boolean,exclude?:string|RegExp}={}) {

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
      process_single_file(filename);
    }
  }

}

export function kernel(_path:string) {
  const kernelver_c =
`#include <fcntl.h>
#include <unistd.h>
#include <stdint.h>
int main(int argc,char* argv[])
{
	if (argc > 1) {
		int fd = open(argv[1],0,O_RDONLY);
		if (fd >= 0 && lseek(fd,526,SEEK_SET) == 526) {
			uint16_t off;
			if (read(fd, &off, 2) == 2 && lseek(fd, off + 0x200, SEEK_SET) == off + 0x200) {
				char c; while (read(fd,&c,1) == 1 && c && c != 0x20) write(1,&c,1); return 0;
			}
		}
	}
	return 1;
}`;
  context.writeSyncLn(`echo ${shell_escape.singleArgument(kernelver_c)} > /tmp/kernelver.c`);
  context.writeSyncLn("gcc -o /tmp/kernelver /tmp/kernelver.c");
  context.writeSyncLn("KERNEL_VERSION=`/tmp/kernelver " + shell_escape.singleArgument(_path) + "`");
  process_single_file(_path);
}

/*
export const dir = runExclusive.build(exclusives,
  async(_path:string) => {

    const src = path.join(context.srcdir,_path);
    if (!Deno.lstatSync(src).isDirectory) throw new Error(`${_path} is not a directory`);

    context.writeSyncLn(`find "${_path}" -exec touch -ch {} ;`);
  }
);
*/

/*
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
*/

export function exec(cmd:string|string[], options:{overlay:boolean} = {overlay:false}) {
  if (Array.isArray(cmd)) {
    context.writeSyncLn(cmd.map(_=>shell_escape.singleArgument(_)).join(' '));
  } else {
    context.writeSyncLn(cmd);
  }
}

//const userInfo = os.userInfo()

const args = parse(Deno.args);

context = new Context(args._[0].toString(), args._[1].toString());

export var ARCH:string = "x86_64";
export var LIB:string = "lib64";

const p = Deno.run({cmd:["chroot", context.srcdir, "scanelf", "-BF", "%a#F", "/bin/sh"],stdout:"piped"})
const status = await p.status();
if (status.success && context.utf8decoder.decode(await p.output()).trim() == "EM_386") {
  console.log("32bit architecture detected.")
  ARCH="i686";
  LIB="lib";
}
context.writeSyncLn(`ARCH=${ARCH}`);
context.writeSyncLn(`LIB=${LIB}`);
context.writeSyncLn("set -e");

console.log("Scanning ELF dependencies...");
const p2 = Deno.run({cmd:["chroot", context.srcdir, "scanelf", "-E", "ET_DYN,ET_EXEC", "-RyBLF", "%F;%r;%n", "/"],stdout:"piped"})

//if (!(await p2.status()).success) throw new Error("Scanning dependencies failed.");
//else

context.utf8decoder.decode(await p2.output()).trim().split("\n").forEach( _ => {
  if (_.trim() != "") {
    const splitted = _.trim().split(';');
    if (splitted.length != 3) throw new Error(`Bad scanelf output: ${_}`)
    //else
    const _path = splitted[0].trim();
    const dirname = path.dirname(_path);
    const rpath = splitted[1].trim() != "-"? splitted[1].trim().replace("$ORIGIN", dirname) : dirname;

    const deps = splitted[2].split(',').map( _ => {
      if (_[0] == '/') return _;
      //else
      for (let rp of rpath.split(':')) {
        if (existsSync(path.join(context.srcdir, rp, _))) return path.join(rp, _);
      }
      if (existsSync(path.join(path.dirname(_path), _))) return path.join(path.dirname(_path), _);
      //else
      throw new Error(`Shared library ${_} referred by ${_path} couldn't be found.  rpath=${rpath}`);
    });

    context.elf_deps.set(_path, deps);
  }
});

console.log(`Scanned ELF dependencies: ${context.elf_deps.size}`);

if (import.meta.main) {
  console.log("main");
}
