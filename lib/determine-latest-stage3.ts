import * as http from "http";
import * as https from "https";
import {Subcommand} from "./subcommand";

function get_url(url:string):Promise<string>
{
  const http_modules = [ http, https ];
  var http_module = http_modules[0];
  if (url.indexOf("https://") === 0) http_module = http_modules[1];
  return new Promise((resolve, reject) => {
    http_module.get(url, (res) => {
      let body = "";
      res.on("data", (chunk)=> {
        body += chunk;
      });
      res.on("end", () => resolve(body));
    }).on("error", (err) => reject(err));
  });
}

export class DetermineLatestStage3 implements Subcommand<[]> {
  command = "determine-latest-stage3";
  description = "determine latest stage3";
  options = [];

  public async run() {
    const base_url = "http://ftp.iij.ad.jp/pub/linux/gentoo/releases/amd64/autobuilds/";
    const data = base_url + (await get_url(base_url + "/latest-stage3-amd64.txt"))
    .split('\n').filter(_=>_.indexOf('#') != 0).filter(Boolean).join().split(' ', 2)[0];
    console.log(data);
    return 0;
  }
}
