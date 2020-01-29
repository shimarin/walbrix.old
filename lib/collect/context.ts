export class Context {
  readonly srcdir:string;
  readonly dstdir:string;
  public lstfiles = new Set<string>();
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
