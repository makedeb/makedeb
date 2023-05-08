use crate::{cache, message::Message, util};
use rust_apt::cache::{Cache, PackageSort};

pub fn autoremove(no_confirm: bool) {
    util::lock_cache();
    let apt_cache = Cache::new();

    for pkg in apt_cache.packages(&PackageSort::default()) {
        if pkg.is_auto_removable() {
            pkg.mark_delete(false);
            pkg.protect();
        }
    }

    if let Err(err) = apt_cache.resolve(true) {
        util::handle_errors(err);
        Message::new()
            .error("An issue was encountered while resolving deps.")
            .send();
        quit::with_code(exitcode::UNAVAILABLE);
    }

    util::unlock_cache();
    cache::run_transaction::<String>(&apt_cache, &[], false, false, no_confirm);
}
