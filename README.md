![GitHub Workflow Status](https://img.shields.io/github/workflow/status/hwittenborn/makedeb/Build%20and%20publish%20to%20repo?label=build%20status&logo=github&style=flat-square)
![GitHub](https://img.shields.io/github/license/hwittenborn/makedeb?style=flat-square)

## Overview ##
makedeb takes PKGBUILD files and creates Debian archives installable with APT

Note: It is highly recommended to install [mpm](https://github.com/hwittenborn/mpm) alongside this program for automated AUR updates.

## Installation ##
Hosting is provided by [Gemfury](https://gemfury.com/)

To install, run the following commands:
```sh
echo "deb [trusted=yes] https://apt.fury.io/hwittenborn/ /" | sudo tee /etc/apt/sources.list.d/hwittenborn.list
sudo apt update
sudo apt install makedeb -y
```

## Usage ##
Instructions can be found after installation with `makedeb --help`

## Get in touch ##
A Matrix room is available at [#git:hunterwittenborn.me](https://matrix.to/#/#git:hunterwittenborn.me) for discussion of any of my projects. Feel free to hop in if you need any help.
