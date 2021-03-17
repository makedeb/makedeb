## Disclaimer ##
While this program is relatively stable, features are constantly being added which may cause it to act up. Do **not** use the program right now if you're expecting stability. Instead, feel free to use it after this disclaimer is no longer here.

## Overview ##
Makedeb takes PKGBUILD files and creates Debian archives installable with APT

## Installation ##
To install, run the following:
```sh
echo "deb [trusted=yes] https://repo.hunterwittenborn.me/apt/ /" | sudo tee /etc/apt/sources.list.d/hunterwittenborn.me.list
sudo apt update
sudo apt install makedeb -y
```

## Building and Installing PKGBUILDs ##
1. Obtain the PKGBUILD and other files if necessary, most often with `git clone url`
2. Run `makedeb` in the directory containing the PKGBUILD. After, install the package with `apt install ./package.deb`, or alternatively specify the `--install` flag when running

## Other Notes ##
Dependencies will need to be manually changed inside the PKGBUILD if the dependency names on Debian differ from the Arch Linux counterparts(or try the [beta] dependency converter with option `--convert`). Keep the formatting in the PKGBUILD the same though(don't add commas, the script automatically formats the control file).

## Things I Want to Add ##
- Automated installation and updates for PKGBUILDs from the AUR(in progress)
