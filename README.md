## Overview ##
makedeb takes PKGBUILD files and creates Debian archives installable with APT

Note: It is highly recommended to install [mpm](https://github.com/hwittenborn/mpm) alongside this program for automated AUR updates.

## Installation ##
Hosting is provided by [Gemfury](https://gemfury.com/). Consider using them if you need hosting for your projects

To install, run the following commands:
```sh
echo "deb [trusted=yes] https://apt.fury.io/hwittenborn/ /" | sudo tee /etc/apt/sources.list.d/hwittenborn.list
sudo apt update
sudo apt install makedeb -y
```



## Usage ##
Instructions can be found after installation with `makedeb --help`
