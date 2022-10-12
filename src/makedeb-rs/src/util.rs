use crate::message;
use rust_apt::util::{self as apt_util, Exception};
use std::fmt::Display;

/// Handle CXX errors.
pub fn handle_errors(err_str: Exception) {
    for msg in err_str.what().split(';') {
        if msg.starts_with("E:") {
            message::error(&[msg.strip_prefix("E:").unwrap()]);
        } else if msg.starts_with("W:") {
            message::warning(&[msg.strip_prefix("W:").unwrap()]);
        };
    }
}

/// Format a list of package names in the way APT would.
pub fn format_apt_pkglist<T: AsRef<str> + Display>(pkgnames: &Vec<T>) {
    // makedeb 'msg2' lines start with 7 characters ('  [->] '), so pretend like we have 7 less characters.
    let term_width = apt_util::terminal_width() - 7;
    let mut output = String::from("");
    let mut current_width = 0;

    for _pkgname in pkgnames {
        let pkgname = _pkgname.as_ref();
        output.push_str(pkgname);
        current_width += pkgname.len();

        if current_width > term_width {
            output.push_str("\n");
            current_width = 0;
        } else {
            output.push(' ');
        }
    }

    message::msg2(&[output]);
}
