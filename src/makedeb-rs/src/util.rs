use crate::message::Message;
use colored::{ColoredString, Colorize};
use rust_apt::util::{self as apt_util, Exception};

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

pub fn format_apt_pkglist<T: AsRef<str>>(pkgnames: &[T]) -> ColoredString {
    // All package lines always start with two spaces, so pretend like we have two
    // less characters.
    let term_width = apt_util::terminal_width() - 2;

    let mut output = String::from("  ");
    let mut current_width = 0;

    for (index, pkgname_ref) in pkgnames.iter().enumerate() {
        let pkgname = pkgname_ref.as_ref();
        output.push_str(pkgname);
        // Add 1 for the space that'll appear if we add another package on this line.
        current_width += pkgname.len() + 1;

        let next_pkgname = match pkgnames.get(index + 1) {
            Some(string) => string.as_ref(),
            None => "",
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
