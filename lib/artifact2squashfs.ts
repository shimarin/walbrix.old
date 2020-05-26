import { parse } from "https://deno.land/std/flags/mod.ts";
import { readJsonSync } from "https://deno.land/std/fs/read_json.ts";
import * as path from "https://deno.land/std/path/mod.ts";

async function main()
{
  const args = parse(Deno.args);
  if (args._.length < 2) {
    console.log("Usage: artifact2squashfs artifactfilename squashfsfilename");
  }

  const artifactfilename = args._[0].toString();
  if (!artifactfilename.endsWith(".artifact")) {
    throw new Error(`Artifact filename ${artifactfilename} is not ending with .artifact suffix`);
  }
  //else
  const artifact = path.basename(artifactfilename).replace(/\.artifact$/, "");
  const artifact_def = readJsonSync(artifactfilename) as any;
  const main_component = artifact_def["main_component"];
  const profile = artifact_def["profile"];

  const status = await Deno.run({cmd:[
    Deno.execPath(), "run", "--allow-all",
    main_component,
    path.join("gentoo", profile),
    path.join("build", artifact)]}).status();

  console.log(status);
}

if (import.meta.main) {
  console.log(Deno.env.get("USER"));
  await main();
}
