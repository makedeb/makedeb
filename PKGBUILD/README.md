# Usage
The `pkgbuild.sh` script generates PKGBUILDs for all releases for Debian, the MPR, and the AUR.

To use, set the following variables to any of the specified values:

- `TARGET`: `local`, `mpr`, or `aur`
- `RELEASE`: `stable`, `beta`, or `alpha`

For example:

```sh
export TARGET=mpr
export RELEASE=stable
```

Then run `./pkgbuild.sh`, which will output a generated PKGBUILD file.
