import * as path from "path";
import * as glob from "glob";
import * as fs from "fs-extra";
import {Context} from "./context";
import {file} from "./file";

export function process_package(context:Context, pkgname:string, options?:{use?:string, no_elf_cache?:boolean, exclude?:string, no_copy?:boolean})
{
  const category_and_name = pkgname.split('/', 2);
  const category = category_and_name.length > 1? category_and_name.shift() : "*";
  const name = category_and_name[0];

  const matched = glob.sync(path.join(context.srcdir, `var/db/pkg/${category}/${name}-*/CONTENTS`)).map (_=> {

    const category = fs.readFileSync(path.join(path.dirname(_), "CATEGORY")).toString().trim();
    const pf = fs.readFileSync(path.join(path.dirname(_), "PF"), "utf-8").trim();
    return {
      name: `${category}/${pf}`,
      category: category,
      pf: pf,
      contents: fs.readFileSync(_, "utf-8").split("\n")
      .filter( _ => _.indexOf("obj ") === 0 || _.indexOf("sym ") === 0 || _.indexOf("dir ") === 0)
      .map(_ => _.split(' ', 2)[1]),
      use: fs.readFileSync(path.join(path.dirname(_), "USE"), "utf-8").replace(/(\r\n|\n|\r)/gm, "").split(" ")
    }
  }).filter(_=> {
    return _.pf.replace(/-r[0-9]+$/, "").replace(/-[^-]+$/, "") == name
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
  if (options?.use && options.use.split(" ").some(_ => _.startsWith('-')? pkg.use.includes(_.replace(/^-/,"")) : !pkg.use.includes(_))) {
    console.log(`Package "${pkg.name}" does not satisfy use flag condition "${options.use}"`);
    process.exit(-1);
  }

  context.packages.add(pkg.name);

  if (options?.no_copy) return; // just make sure package is installed

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
      && (!filename.startsWith("/usr/share/locale/") || included_locales.some( _ => filename.startsWith("/usr/share/locale/" + _ + '/')))
      && (!options.exclude || !filename.match(options.exclude))) {
      file(context, filename, options?.no_elf_cache);
    }
  });
}
