## Disclaimer ##
While this program is relatively stable, features are constantly being added which may cause it to act up. Do **not** use the program right now if you're expecting stability. Instead, feel free to use it after this disclaimer is no longer here

## Overview ##
Makedeb takes PKGBUILD files and creates Debian archives installable with APT

*Note:* it is highly recommended to install [makedeb-get](https://github.com/hwittenborn/makedeb-get) alongside this program for automated AUR updates.

## Installation ##
To install, run the following:
```sh
echo "deb [trusted=yes] https://repo.hunterwittenborn.me/apt/ /" | sudo tee /etc/apt/sources.list.d/hunterwittenborn.me.list
sudo apt update
sudo apt install makedeb -y
```

## Usage ##
Instructions can be found after installing with `makedeb --help`
