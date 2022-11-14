# Usage
The `pkgbuild.sh` script generates PKGBUILDs for all releases for Debian and the MPR.

To use, set the following variables to any of the specified values:

- `TARGET`: `apt`, or `mpr` (use `apt` when building locally)
- `RELEASE`: `stable`, `beta`, or `alpha`

> If you want the package to build from the current local Git repository, pass in the `LOCAL` environment variable, set to any value. Note that the PKGBUILD must be used from inside the current repository though.

> This script checks the releases on GitHub to find the version to put into the generated PKGBUILD. By default the script uses the latest version for the current `${RELEASE}`, but if the `{pkgrel}` already exists for the current `{pkgver}` on the current version (i.e. `1.0.0-1` exists), then you can automatically bump the pkgrel (i.e. into `1.0.0-2`) by passing in `BUMP_PKGREL=1`.

> By default the script bumps the `pkgrel` up one past the one on the latest GitHub release for the specified `${RELEASE}`. You can disable this behavior and use the current release by passing in `CURRENT_RELEASE=1` into the script.

For example:

```sh
export TARGET=mpr
export RELEASE=stable
```

Then run `./pkgbuild.sh`, which will output a generated PKGBUILD file.
