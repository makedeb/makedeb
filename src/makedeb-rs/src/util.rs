use crate::message::Message;
use rust_apt::util::{self as apt_util, Exception};
use colored::{ColoredString, Colorize};

/// Handle CXX errors.
pub fn handle_errors(err_str: Exception) {
    let mut makedeb_msg = Message::new();

    for msg in err_str.what().split(';') {
        if msg.starts_with("E:") {
            makedeb_msg = makedeb_msg.error(msg.strip_prefix("E:").unwrap());
        } else if msg.starts_with("W:") {
            makedeb_msg = makedeb_msg.warning(msg.strip_prefix("W:").unwrap());
        };
    }

    makedeb_msg.send();
}

pub fn format_apt_pkglist<T: AsRef<str>>(pkgnames: &Vec<T>) -> ColoredString {
    // All package lines always start with two spaces, so pretend like we have two
    // less characters.
    let term_width = apt_util::terminal_width() - 2;
    let mut output = String::from("  ");
    let mut current_width = 0;

    for (index, _pkgname) in pkgnames.iter().enumerate() {
        let pkgname = _pkgname.as_ref();
        output.push_str(pkgname);
        current_width += pkgname.len();

        let next_pkgname = match pkgnames.get(index + 1) {
            Some(string) => string.as_ref(),
            None => ""
        };

        if current_width + next_pkgname.len() > term_width {
            output.push_str("\n  ");
            current_width = 0;
        } else {
            output.push(' ');
        }
    }

    output.bold()
}