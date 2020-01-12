import * as fs from "fs-extra";
import {Subcommand} from "./subcommand";

function getbyte(fd):[boolean,number]
{
  const buf = Buffer.alloc(1);
  if (fs.readSync(fd, buf, 0, 1, null) < 1) return [false, null];
  //else
  return [true, buf[0]];
}

export function get_kernel_version_string(filename):string
{
  let fd = fs.openSync(filename, "r");
  let buf = Buffer.alloc(526);
  try {
    fs.readSync(fd, buf, 0, buf.byteLength, null);
    buf = Buffer.alloc(2);
    if (fs.readSync(fd, buf, 0, buf.byteLength, null) < 2) return "ERROR";
  }
  finally {
    fs.closeSync(fd);
  }
  fd = fs.openSync(filename, "r");
  try {
    buf = Buffer.alloc(buf[0] + buf[1] * 256 + 0x200);
    fs.readSync(fd, buf, 0, buf.byteLength, null);

    var kernelver = "";
    var r = getbyte(fd);
    while (r[0] && r[1] != 0 && r[1] != 0x20/*space*/) {
      kernelver += String.fromCharCode(r[1]);
      r = getbyte(fd);
    }
    return kernelver;
  }
  finally {
    fs.closeSync(fd);
  }
}

export class KernelVer implements Subcommand<[string]> {
  command = "kernelver <kernelimage>";
  description = "get kernel version string";
  options = [];

  public async run(filename) {
    console.log(get_kernel_version_string(filename));
    return 0;
  }
}
