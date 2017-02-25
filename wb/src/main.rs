extern crate docopt;
extern crate sdl;
extern crate cpython;
extern crate rustc_serialize;

use cpython::{Python, PyDict, PyResult};
use std::os::unix::process::CommandExt;

static USAGE: &'static str = "
Usage:
    wb hoge <hoge-fuga>...
    wb <other-cmd> [<other-cmd-args>...]
";

#[derive(RustcDecodable, Debug)]
struct Args {
    cmd_hoge: bool,
    arg_hoge_fuga: Vec<String>,
    arg_other_cmd: String,
    arg_other_cmd_args: Vec<String>
}

const WBUI_BASE:&'static str = "/usr/share/wbui";

fn fallback_to_python(cmd:String, args:Vec<String>) {
    std::env::set_var("PYTHONPATH", WBUI_BASE);
    let python_module_name = cmd; // TODO: ajust to python naming rules (- to _, import to import_vm)
    let wbui_dir = std::path::Path::new(WBUI_BASE);
    let py = wbui_dir.join(format!("cli2/{}.py", python_module_name));
    let pyc = wbui_dir.join(format!("cli2/{}.pyc", python_module_name));
    if py.exists() || pyc.exists() {
        std::process::Command::new("python2.7").arg("-m").arg(format!("cli2.{}", python_module_name)).args(&args).exec();
    }
    // else
    std::process::Command::new("python2.7").arg(format!("{}/wb.pyc", WBUI_BASE)).arg(python_module_name/*should be cmd*/).args(&args).exec();
}

pub fn main() {
    let args: Args = docopt::Docopt::new(USAGE).and_then(|d| d.decode()).unwrap_or_else(|e| e.exit());
    if args.cmd_hoge {
        println!("Hoge: {:?}", args.arg_hoge_fuga);
    } else {
        fallback_to_python(args.arg_other_cmd, args.arg_other_cmd_args);
    }
}
