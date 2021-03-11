## Overview ##
Makedeb takes PKGBUILD files and creates Debian archives installable with APT

## Ideology ##
Makdeb is NOT a clone/fork of `makepkg`. Rather, Makedeb is written from scratch, striving only to be compatible with the PKGBUILD format as described in the [Arch Wiki](https://wiki.archlinux.org/index.php/PKGBUILD).

## Bulding and Installing Packages ##
1. Obtain the PKGBUILD and other files if necessary, most often with `git clone *URL*`
2. Run `makedeb` in the directory containing the PKGBUILD. After, install the package with `apt install ./*PKGNAME*.deb`

## Updating Packages ##
Obtain the latest PKGBUILD and other files if needed, and follow step 2 listed above.
