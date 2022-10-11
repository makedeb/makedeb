# Usage
The `pkgbuild.sh` script generates PKGBUILDs for all releases for Debian, the MPR, and the AUR.

To use, set the following variables to any of the specified values:

- `TARGET`: `apt`, `mpr`, or `aur` (use `apt` when building locally)
- `RELEASE`: `stable`, `beta`, or `alpha`

> If you want the package to build from the current local Git repository, pass in the `LOCAL` environment variable, set to any value. Note that the PKGBUILD must be used from inside the current repository though.

For example:

```sh
export TARGET=mpr
export RELEASE=stable
```

Then run `./pkgbuild.sh`, which will output a generated PKGBUILD file.
