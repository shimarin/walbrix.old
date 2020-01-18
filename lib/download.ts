import * as crypto from "crypto";
import {spawnSync} from "child_process";
import * as path from "path";
import * as fs from "fs-extra";
import {Command} from "commander";
import {Subcommand} from "./subcommand";

const download_cache_dir = path.join(".", "cache", "download");

function urlhash(url:string) { return crypto.createHash('md5').update(url).digest('hex'); }

export function download(url:string):string
{
  const cache_filename = path.join(download_cache_dir, urlhash(url));
  try {
    fs.statSync(cache_filename);
    return cache_filename; // cache hit
  }
  catch (e) {;}

  fs.mkdirpSync(download_cache_dir);
  const tmpfile = path.join(download_cache_dir, `download-${process.pid}.temp`);
  if (spawnSync("wget", [ "-O", tmpfile, url], {stdio:"inherit"}).status !== 0) {
    fs.unlinkSync(tmpfile)
    throw new Error(`Download failed. '${url}'`);
  }
  // else
  fs.moveSync(tmpfile, cache_filename);
  return cache_filename;
}

export class Download implements Subcommand<[string,Command]> {
  command = "download <URL>";
  description = "download a file";
  options = [
    ["-h --hash", "print URL hash"] as [string,string]
  ];

  public async run(url,options:Command) {
    if (options.hash) {
      process.stdout.write(urlhash(url) + "\n");
      return;
    }

    // else
    const cache_filename = download(url);

    console.log("File saved as " + cache_filename);
  }
}
