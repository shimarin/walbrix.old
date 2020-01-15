import * as crypto from "crypto";
import {spawnSync} from "child_process";
import * as path from "path";
import * as fs from "fs-extra";
import {Command} from "commander";
import {Subcommand} from "./subcommand";

const download_cache_dir = path.join(".", "download_cache");

export class Download implements Subcommand<[string,Command]> {
  command = "download <URL>";
  description = "download a file";
  options = [
    ["-h --hash", "print URL hash"] as [string,string]
  ];

  public async run(url,options:Command) {

    const urlhash = crypto.createHash('md5').update(url).digest('hex');

    if (options.hash) {
      process.stdout.write(urlhash + "\n");
      return;
    }

    const cache_filename = path.join(download_cache_dir, urlhash);
    try {
      fs.statSync(cache_filename);
      return;
    }
    catch (e) {;}

    const tmpfile = `download-temp-${process.pid}`;
    if (spawnSync("wget", [ "-O", tmpfile, url], {stdio:"inherit"}).status === 0) {
      fs.moveSync(tmpfile, cache_filename);
    } else {
      fs.unlinkSync(tmpfile)
      return;
    }

    console.log("File saved as " + cache_filename);
  }
}
