// subcommands
pub mod ui;
pub mod hoge;

use std;
use std::path::{Path,PathBuf};
use regex::Regex;

pub fn wbui_base() -> &'static str {
    lazy_static! {
        static ref WBUI_BASE: String = match std::env::var_os("WBUI_BASE") {
            Some(wbui_base) => wbui_base.to_str().unwrap().to_string(),
            None => "/usr/share/wbui".to_string()
        };
    }
    &WBUI_BASE
}

pub fn wbui_file_path(path: &str) -> PathBuf {
    lazy_static! {
        static ref LEADING_SLASHES: Regex = Regex::new(r"^/+").unwrap();
    }
    Path::new(&wbui_base()).join(LEADING_SLASHES.replace(path, "").to_string())
}

#[test]
fn test_wbui_base() {
    assert_eq!(wbui_base(), "/usr/share/wbui");
}

#[test]
fn test_wbui_file_path() {
    assert_eq!(wbui_file_path("hoge/fuga.py"), Path::new("/usr/share/wbui/hoge/fuga.py"));
    assert_eq!(wbui_file_path("/hoge/fuga.py"), Path::new("/usr/share/wbui/hoge/fuga.py"));
    assert_eq!(wbui_file_path("//hoge/fuga.py"), Path::new("/usr/share/wbui/hoge/fuga.py"));
}
