use crate::message::Message;
use rust_apt::util::Exception;

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
