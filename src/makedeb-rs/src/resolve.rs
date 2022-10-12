use crate::{message, util};
use rust_apt::{
    cache::{Cache, PackageSort},
    progress::{AptAcquireProgress, AptInstallProgress},
};
use std::io;

pub(crate) fn resolve(
    pkglist: Vec<String>,
    allow_downgrades: bool,
    no_confirm: bool,
    fail_on_change: bool,
) {
    if users::get_effective_uid() != 0 {
        message::error(&["Dependency resolver was ran under a non-root user."]);
        quit::with_code(exitcode::USAGE);
    }

    let mut pkgs = vec![];
    let mut debs = vec![];

    for pkg in &pkglist {
        let (pkgname, deb) = pkg.split_once('!').unwrap();
        pkgs.push(pkgname);
        debs.push(deb);
    }

    let cache = Cache::debs(&debs).unwrap_or_else(|err| {
        util::handle_errors(err);
        message::error(&["Unable to open cache in dependency resolver."]);
        quit::with_code(exitcode::UNAVAILABLE);
    });


    // Mark debs for installation and resolve their deps.
    for pkgname in &pkgs {
        ["emacs", "krita", "makedeb-beta"].iter().map(|pkg| {
            println!("== {} ==", pkg);
            cache.get(pkg.clone()).unwrap();
        }).for_each(drop);
        println!("== DONE ({}) ==", pkgname);

        let pkg = cache.get(pkgname).unwrap();
        pkg.mark_install(true, true).then_some(()).unwrap();
        pkg.protect();
    }

    if let Err(err) = cache.resolve(false) {
        util::handle_errors(err);
        message::error(&["An issue was encountered while resolving deps."]);
        quit::with_code(exitcode::UNAVAILABLE);
    }

    let mut to_install = vec![];
    let mut to_remove = vec![];
    let mut to_upgrade = vec![];
    let mut to_downgrade = vec![];

    for pkg in cache.packages(&PackageSort::default()) {
        if pkgs.contains(&pkg.name().as_str()) {
        } else if pkg.marked_install() {
            to_install.push(pkg.name().to_string());
        } else if pkg.marked_delete() {
            to_remove.push(pkg.name().to_string());
        } else if pkg.marked_upgrade() {
            to_upgrade.push(pkg.name().to_string());
        } else if pkg.marked_downgrade() {
            to_downgrade.push(pkg.name().to_string());
        } else if pkg.marked_keep() {
        } else {
            unreachable!();
        }
    }

    if to_install.is_empty()
        && to_remove.is_empty()
        && to_upgrade.is_empty()
        && to_downgrade.is_empty()
    {
        quit::with_code(exitcode::OK);
    }

    if fail_on_change {
        message::error(&["The following dependencies aren't installed, but are required in order to build the package:"]);

        let mut user_pkgs = vec![];
        for pkg in to_install {
            if pkgs.contains(&pkg.as_str()) {
                user_pkgs.push(pkg);
            }
        }

        message::error2(&user_pkgs);
        quit::with_code(exitcode::USAGE);
    }

    if !to_install.is_empty() {
        message::msg(&["The following packages will be installed:"]);
        util::format_apt_pkglist(&to_install);
    }
    if !to_remove.is_empty() {
        message::msg(&["The following packages will be removed:"]);
        util::format_apt_pkglist(&to_remove);
    }
    if !to_upgrade.is_empty() {
        message::msg(&["The following packages will be upgraded:"]);
        util::format_apt_pkglist(&to_upgrade);
    }
    if !to_downgrade.is_empty() {
        if !allow_downgrades {
            message::error(
                &["Package downgrades are required but '--allow-downgrades' wasn't passed."]
            );
            quit::with_code(exitcode::USAGE);
        }

        message::msg(&["The following packages will be DOWNGRADED:"]);
        util::format_apt_pkglist(&to_downgrade);
    }
    println!();

    let response = if no_confirm {
        String::from("y")
    } else {
        message::question(&["Would you like to continue? [Y/n] "]);
        let mut input = String::new();
        io::stdin().read_line(&mut input).unwrap();
        input
    };

    if !["y", ""].contains(&response.to_lowercase().as_str()) {
        message::msg(&["Aborting..."]);
        quit::with_code(exitcode::USAGE);
    }

    let mut acquire_progress = AptAcquireProgress::new_box();
    if let Err(err) = cache.get_archives(&mut acquire_progress) {
        util::handle_errors(err);
        message::error(&["Failed to fetch needed archives."]);
        quit::with_code(exitcode::UNAVAILABLE);
    }

    let mut install_progress = AptInstallProgress::new_box();
    if let Err(err) = cache.do_install(&mut install_progress) {
        util::handle_errors(err);
        message::error(&["Failed to run transaction."]);
        quit::with_code(exitcode::UNAVAILABLE);
    }
}
