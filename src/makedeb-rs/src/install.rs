use crate::{cache, message::Message, util};
use rust_apt::cache::Cache;
use std::process::Command;
use tempfile::TempPath;

struct Package {
    pkgname: String,
    version: String,
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
    as_deps: bool,
) {
    util::lock_cache();

    let mut pkgs = vec![];
    let mut pkgnames = vec![];
    let mut debs = vec![];

    for deb in &deblist {
        let deb_tmp = format!(
            "/tmp/{}",
            std::path::PathBuf::from(deb)
                .file_name()
                .to_owned()
                .unwrap()
                .to_str()
                .unwrap()
        );
        std::fs::copy(&deb, &deb_tmp).unwrap();
        let deb = TempPath::from_path(deb_tmp);

        let args = ["-f", deb.to_str().unwrap()];
        let pkgname_bare = std::str::from_utf8(
            &Command::new("dpkg-deb")
                .args(args)
                .arg("Package")
                .output()
                .unwrap()
                .stdout,
        )
        .unwrap()
        .trim()
        .to_string();
        let version = std::str::from_utf8(
            &Command::new("dpkg-deb")
                .args(args)
                .arg("Version")
                .output()
                .unwrap()
                .stdout,
        )
        .unwrap()
        .trim()
        .to_string();
        let architecture = std::str::from_utf8(
            &Command::new("dpkg-deb")
                .args(args)
                .arg("Architecture")
                .output()
                .unwrap()
                .stdout,
        )
        .unwrap()
        .trim()
        .to_string();
        let pkgname = format!("{pkgname_bare}:{architecture}");
        pkgnames.push(pkgname.clone());
        pkgs.push(Package { pkgname, version });
        debs.push(deb);
    }

    let mut apt_cache = Cache::debs(
        debs.iter()
            .map(|deb| deb.to_str().unwrap())
            .collect::<Vec<_>>()
            .as_slice(),
    )
    .unwrap_or_else(|err| {
        util::handle_errors(err);
        Message::new()
            .error("Unable to open cache in dependency resolver")
            .send();
        quit::with_code(exitcode::UNAVAILABLE);
    });

    // Mark debs for installation and resolve their deps.
    for pkg in &pkgs {
        let apt_pkg = apt_cache.get(&pkg.pkgname).unwrap();
        let ver = apt_pkg.get_version(&pkg.version).unwrap();
        ver.set_candidate();

        // For some reason this first argument, `auto_inst` (https://docs.rs/rust-apt/latest/rust_apt/package/struct.Package.html#auto_inst) needs to be set to `true` for removal of packages to work. Need to find out why.
        apt_pkg.mark_install(false, !as_deps).then_some(()).unwrap();
        apt_pkg.protect();
    }

    if let Err(err) = apt_cache.resolve(false) {
        util::handle_errors(err);
        Message::new()
            .error("An issue was encountered while resolving deps.")
            .send();
        quit::with_code(exitcode::UNAVAILABLE);
    }

    // If we aren't installing the '.deb' packages themselves, then make them not marked for installation.
    // Currently we have to do this by rebuilding the cache and mirroring the changes into the new cache.
    if deps_only {
        let new_cache = Cache::new();

        for pkg in apt_cache.get_changes(false) {
            let pkgname = pkg.fullname(false);
            let version = pkg.candidate().unwrap().version();

            if pkgnames.contains(&pkgname) {
                continue;
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

        apt_cache = new_cache;
    }

    util::unlock_cache();
    cache::run_transaction(
        &apt_cache,
        debs.iter()
            .map(|deb| deb.to_str().unwrap())
            .collect::<Vec<_>>()
            .as_slice(),
        fail_on_change,
        allow_downgrades,
        no_confirm,
    );
}
