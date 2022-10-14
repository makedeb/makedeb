use crate::{message::Message, util};
use rust_apt::{
    cache::{Cache, PackageSort},
    progress::{AptAcquireProgress, AptInstallProgress},
};
use std::{io, process::Command};

struct Package {
    pkgname: String,
    version: String
}

impl PartialEq for Package {
    fn eq(&self, other: &Self) -> bool {
        self.pkgname == other.pkgname
    }
}

pub(crate) fn install(
    deblist: Vec<String>,
    allow_downgrades: bool,
    no_confirm: bool,
    fail_on_change: bool,
    deps_only: bool,
    as_deps: bool
) {
    if users::get_effective_uid() != 0 {
        Message::new().error("Dependency resolver was ran under a non-root user.").send();
        quit::with_code(exitcode::USAGE);
    }

    let mut pkgs = vec![];
    let mut pkgnames = vec![];
    let mut debs = vec![];

    for deb in &deblist {
        let args = ["-f", deb.as_str()];
        let pkgname = std::str::from_utf8(&Command::new("dpkg-deb").args(&args).arg("Package").output().unwrap().stdout).unwrap().trim().to_string();
        let version = std::str::from_utf8(&Command::new("dpkg-deb").args(&args).arg("Version").output().unwrap().stdout).unwrap().trim().to_string();
        pkgnames.push(pkgname.clone());
        pkgs.push(Package { pkgname, version });
        debs.push(deb);
    }


    let mut cache = Cache::debs(&debs).unwrap_or_else(|err| {
        util::handle_errors(err);
        Message::new().error("Unable to open cache in dependency resolver").send();
        quit::with_code(exitcode::UNAVAILABLE);
    });


    // Mark debs for installation and resolve their deps.
    for pkg in &pkgs {
        let apt_pkg = cache.get(&pkg.pkgname).unwrap();
        let ver = apt_pkg.get_version(&pkg.version).unwrap();
        ver.set_candidate();

        apt_pkg.mark_install(false, !as_deps).then_some(()).unwrap();
        apt_pkg.protect();
    }

    if let Err(err) = cache.resolve(false) {
        util::handle_errors(err);
        Message::new().error("An issue was encountered while resolving deps.").send();
        quit::with_code(exitcode::UNAVAILABLE);
    }

    // If we aren't installing the '.deb' packages themselves, then make them not marked for installation.
    // Currently we have to do this by rebuilding the cache and mirroring the changes into the new cache.
    if deps_only {
        let new_cache = Cache::new();

        for pkg in cache.get_changes(false) {
            let pkgname = pkg.name();
            let version = pkg.candidate().unwrap().version();

            if pkgnames.contains(&pkgname) {
                continue
            }

            let new_pkg = new_cache.get(&pkgname).unwrap();
            let new_ver = new_pkg.get_version(&version).unwrap();
            new_ver.set_candidate();

            if pkg.marked_install() {
                new_pkg.mark_install(false, false);
            } else if pkg.marked_delete() {
                new_pkg.mark_delete(false);
            } else if pkg.marked_upgrade() {
                new_pkg.marked_upgrade();
            } else if pkg.marked_downgrade() {
                new_pkg.marked_downgrade();
            } else {
                unreachable!();
            }

            new_pkg.protect();
        }

        cache = new_cache;
    }

    let mut to_install = vec![];
    let mut to_remove = vec![];
    let mut to_upgrade = vec![];
    let mut to_downgrade = vec![];

    for pkg in cache.packages(&PackageSort::default()) {
        if pkg.marked_install() {
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

    // `fail_on_change` is only encountered when installing build dependencies, so we can use build-dep specific terminology here.
    if fail_on_change {
        let mut msg = Message::new().error("The following dependencies aren't installed, but are required in order to build the package:");

        // Reopen the deb cache if it's been closed by the `if deps_only` block above.
        let deb_cache = Cache::debs(&debs).unwrap();

        // Get the list of direct dependencies of the `.deb` packages.
        let mut direct_deps = vec![];

        for pkg in pkgs {
            let version = deb_cache.get(&pkg.pkgname).unwrap().get_version(&pkg.version).unwrap();

            if let Some(apt_deps) = version.dependencies() {
                for dep in apt_deps {
                    direct_deps.append(&mut dep.base_deps.iter().map(|dep| dep.name().to_string()).collect::<Vec<String>>());
                }
            }
        }

        for pkg in cache.get_changes(false) {
            let pkgname = pkg.name();

            if pkg.marked_install() && direct_deps.contains(&pkgname) {
                msg = msg.error2(pkgname);
            }
        }

        msg = msg.error("Trying running with '-s' (i.e. 'makedeb -s').");
        msg.send();
        quit::with_code(exitcode::USAGE);
    }

    let mut msg = Message::new();

    let add_pkgs = |mut msg: Message, pkgs: &mut Vec<String>| -> Message {
        pkgs.sort();

        for pkg in pkgs {
            msg = msg.msg2(pkg);
        }

        msg
    };

    if !to_install.is_empty() {
        msg = msg.msg("The following packages will be installed:");
        msg = add_pkgs(msg, &mut to_install);
    }
    if !to_remove.is_empty() {

        msg = msg.msg("The following packages will be removed:");
        msg = add_pkgs(msg, &mut to_remove);
    }
    if !to_upgrade.is_empty() {
        msg = msg.msg("The following packages will be upgraded:");
        msg = add_pkgs(msg, &mut to_upgrade);
    }
    if !to_downgrade.is_empty() {
        if !allow_downgrades {
            Message::new().error("Package downgrades are required but '--allow-downgrades' wasn't passed.").send();
            quit::with_code(exitcode::USAGE);
        }

        msg = msg.msg("The following packages will be DOWNGRADED:");
        msg = add_pkgs(msg, &mut to_downgrade);
    }

    if !no_confirm {
        msg.no_style("").question("Would you like to continue? [Y/n] ").send();
        let mut response = String::new();
        io::stdin().read_line(&mut response).unwrap();

        if !["y", ""].contains(&response.trim().to_lowercase().as_str()) {
            Message::new().error("Aborting...").send();
            quit::with_code(exitcode::USAGE);
        }
    };


    let mut acquire_progress = AptAcquireProgress::new_box();
    if let Err(err) = cache.get_archives(&mut acquire_progress) {
        util::handle_errors(err);
        Message::new().error("Failed to fetch needed archives.").send();
        quit::with_code(exitcode::UNAVAILABLE);
    }

    let mut install_progress = AptInstallProgress::new_box();
    if let Err(err) = cache.do_install(&mut install_progress) {
        util::handle_errors(err);
        Message::new().error("Failed to run transaction.").send();
        quit::with_code(exitcode::UNAVAILABLE);
    }
}
