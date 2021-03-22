## Overview ##
makedeb takes PKGBUILD files and creates Debian archives installable with APT

Note: It is highly recommended to install [mpm](https://github.com/hwittenborn/mpm) alongside this program for automated AUR updates.

## Installation ##
To install, run the following:
```sh
echo "deb [trusted=yes] https://repo.hunterwittenborn.me/apt/ /" | sudo tee /etc/apt/sources.list.d/hunterwittenborn.me.list
sudo apt update
sudo apt install makedeb -y
```

## Usage ##
Instructions can be found after installation with `makedeb --help`
