extern crate docopt;
extern crate sdl;
//extern crate cpython;
extern crate rustc_serialize;
extern crate regex;
#[macro_use] extern crate lazy_static;

//use cpython::{Python, PyDict, PyResult};

mod wb;

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

fn fallback_to_python(cmd:&str, args:Vec<String>) {
    let wbui_base = &wb::wbui_base();
    let python_module_name = &match cmd {
        "import" => "import_vm".to_string(),
        x => x.replace("-", "_")
    };

    use std::os::unix::process::CommandExt;
    std::env::set_var("PYTHONPATH", wbui_base);
    let mut python = std::process::Command::new("python2.7");

    if ["py", "pyc"].iter().any(|suffix| wb::wbui_file_path(&format!("cli2/{}.{}", python_module_name, suffix)).exists()) {
        python.arg("-m").arg(format!("cli2.{}", python_module_name)).args(&args).exec();
    }
    // else
    python.arg(format!("{}/wb.pyc", wbui_base)).arg(cmd).args(&args).exec();
}

pub fn main() {
    let args: Args = docopt::Docopt::new(USAGE).and_then(|d| d.decode()).unwrap_or_else(|e| e.exit());
    if args.cmd_hoge {
        wb::hoge::main(args.arg_hoge_fuga);
    } else {
        fallback_to_python(&args.arg_other_cmd, args.arg_other_cmd_args);
    }
}
