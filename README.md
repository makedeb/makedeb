<h1 align="center">Makedeb</h1>

<div align="center">
<a href="https://drone.hunterwittenborn.com/hwittenborn/makedeb">
  <img src="https://drone.hunterwittenborn.com/api/badges/hwittenborn/makedeb/status.svg" />
</a>
</div>

## Overview ##
makedeb takes PKGBUILD files and creates Debian archives installable with APT

*Automated installation and updates of AUR packages are available with [mpm](https://github.com/hwittenborn/mpm).*

## Installation ##
To install, run the following commands:
```sh
sudo wget 'https://hunterwittenborn.com/keys/apt.asc' -O /etc/apt/trusted.gpg.d/hwittenborn.asc
echo 'deb [arch=all] https://repo.hunterwittenborn.com/debian/makedeb any main' | sudo tee /etc/apt/sources.list.d/makedeb.list
sudo apt update
sudo apt install makedeb
```

## Usage ##
Instructions can be found after installation with `makedeb --help`

## Get in touch ##
A Matrix room is available at [#git:hunterwittenborn.com](https://matrix.to/#/#git:hunterwittenborn.com) for discussion of any of my projects. Feel free to hop in if you need any help.
