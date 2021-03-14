## Overview ##
Makedeb takes PKGBUILD files and creates Debian archives installable with APT


## Building and Installing Packages ##
1. Download and install makepkg.deb from this repo
2. Obtain the PKGBUILD and other files if necessary, most often with `git clone url`
3. Run `makedeb` in the directory containing the PKGBUILD. After, install the package with `apt install ./*PKGNAME*.deb`, or alternatively specify the `--install` flag when running

## Quick Notes ##
- Dependencies might need to be changed inside the PKGBUILD [as of now](https://github.com/hwittenborn/makedeb#things-i-want-to-add). Keep the formatting in the PKGBUILD the same though(don't add commas, the script automatically formats the control file).

## Things I Still *Need* to Add ##
 - Pushing environment variables to makepkg

## Things I Want to Add ##
Dependency substitution system(for converting Arch Linux dependencies to Debian dependencies)
