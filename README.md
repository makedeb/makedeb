## Overview ##
Makedeb takes PKGBUILD files and creates Debian archives installable with APT

## Installation ##
To install, run the following:
```sh
echo "deb [trusted=yes] https://repo.hunterwittenborn.me/apt/ /" | sudo tee /etc/apt/sources.list.d/hunterwittenborn.me.list
sudo apt update
sudo apt install makedeb -y
```

## Building ##
1. Clone/Download this repo
2. Run `./makedeb`

## Building and Installing PKGBUILDs ##
1. Obtain the PKGBUILD and other files if necessary, most often with `git clone url`
2. Run `makedeb` in the directory containing the PKGBUILD. After, install the package with `apt install ./*PKGNAME*.deb`, or alternatively specify the `--install` flag when running

## Other Notes ##
Dependencies will need to be manually changed inside the PKGBUILD if the dependency names on Debian differ from the Arch Linux counterparts. Keep the formatting in the PKGBUILD the same though(don't add commas, the script automatically formats the control file).

## Things I Still *Need* to Add ##
- Pushing environment variables to makepkg
- Picking a file(i.e. a file named other than PKGBUILD)

## Things I Want to Add ##
- Dependency substitution system(for converting Arch Linux dependencies to Debian dependencies)
- Automated installation and updates for PKGBUILDs from the AUR
