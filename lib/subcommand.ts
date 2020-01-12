export interface Subcommand<Args extends any[]> {
  readonly command:string;
  readonly description:string;
  readonly options:[string,string][];
  run(...args:Args);
}
