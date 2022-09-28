# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Note that the `[Unreleased]` section contains all changes that haven't yet made it to the `stable` branch.

## [Unreleased]
### Added
- Added `--no-build` and `--no-check` options (#211).
- Added extension support (#212).
- Format makedeb-styled message calls (`msg`, `msg2`, `warning`, etc.) in PKGBUILD functions with a prefix (#212).
- Added support for the `NO_COLOR` environment variable (#188).
- Allow `MAKEDEB_DPKG_ARCHITECTURE` and `MAKEDEB_DISTRO_CODENAME` to be overwritten by the user (#227).

### Removed
- Dropped support for VCS systems besides Git and SVN (#210).

### Fixed
- Fixed bug where dotfiles are found in the package root (#229).

## [15.1.0] - 2022-06-29
### Added
- Add support for `:` characters in dependencies (#202).

## [15.0.2] - 2022-06-05
### Fixed
- Error properly when a needed VCS package isn't installed (#197).
- Add `--no-color` option to disable colored output from makedeb (#200).
- Add missing newline in `makedeb --mpr-check` output.

## [15.0.1] - 2022-05-25
### Fixed
- Convert relationship operators for dependencies defined in `package()` (#191).

## [15.0.0] - 2022-05-22
### Changed
- Require `pkgver` to start with a digit (#186).

## [14.1.3] - 2022-05.21
### Added
- Add support for custom installing directories during builds (#61).
- Add support for `|` characters in dependency fields.
- Add CLI options to print makedeb-styled message (#156).
- Show error when trying to build Pacstall (#179).

### Fixed
- Allow epochs and pkgrels in dependency version restrictors (#182).

## [14.1.2] - 2022-05-07
### Fixed
- Add compatibility alias for `--print-srcinfo` (#173).

## [14.1.1] - 2022-04-30
### Added
- Added `--pass-env` option to pass the user's enviroment variables to `sudo` calls.
- Added `--allow-downgrades` to pass the option to `apt` calls.

### Fixed
- Add conffiles to built packages (#168).

## [14.1.0] - 2022-04-30
### Added
- Add `build-essential` as a dependency to install makedeb.

## [14.0.5] - 2022-04-29
### Fixed
- Add missing '-z' flag to 'tar' commands used to create gz archives in built packages.

## [14.0.4] - 2022-04-29
### Fixed
- Fix unknown error when checking hashsums with `--skip-pgp-check`.

## [14.0.2] - 2022-04-19
### Fixed
- Revert ZSTD support in built archives, as Debian 11 doesn't support them (#158).

## [14.0.1] - 2022-04-19
### Fixed
-  Fix '--no-confirm' not working properly during builds (#157).

## [14.0.0] - 2022-04-16
### Added
- Added `BUILDING.md`.

### Changed
- Show a warning when using Arch Linux styled architectures (those can be seen from the output of `uname -p`). Such architectures are still allowed for builds, but makedeb prompts the user to switch the architecture listing in the PKGBUILD to the Debian styled one (which can be seen from the output of `dpkg --print-architecture`).
- Updated `CONTRIBUTING.md` with better guidelines.
- Require `pkgdesc` to not be empty and contain characters other than spaces.
- Show warning when `pkgdesc` or a maintainer entry isn't present in PKGBUILDs.
- Show warning when more than one maintainer is specified.
- Disallow distribution and architecture-specific variables from pairing up with each other (#150).
- Require sources with distribution or architecture extensions in the variable name to have a matching hashsum entry with the same extensions (#150).
- Update format of .SRCINFO files.

### Deprecated
- An architecture listing of `any` now sets the package architecture to the system's DPKG architecture (as required by the [Debian control file specification](https://www.debian.org/doc/debian-policy/ch-controlfields.html#s-f-architecture)). Previously `any` was automatically converted to `all` (which identifies an architecture-independent package), and using `all` now fulfills that purpose.
- Removed the `--ignorearch`, `--nodeps`, `--geninteg`, `-Q`/`--no-fields`, and `-v`/`--distro-packages` options. `--ignorearch`, `--nodeps`, and `--geninteg`, should now be replaced with their hyphen-separated counterparts, with those being `--ignore-arch`, `--no-deps`, and `--gen-integ` respectively. All other previously mentioned options have been fully removed.

### Fixed
- Implemented a changelog (#145).
- Moved all code to `src/makepkg` codebase (#130).
- Disabled all colored output if file descriptor 2 isn't a terminal (#81).
- Allow `pkgver` to include all characters allowed in the [Debian control file specification](https://www.debian.org/doc/debian-policy/ch-controlfields.html#s-f-version).
- Don't require `pkgver` to start with a number.
