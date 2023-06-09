# makedeb
[![Deployment - Stable](https://img.shields.io/drone/build/makedeb/makedeb/stable?label=stable&logo=drone&server=https%3A%2F%2Fdrone.hunterwittenborn.com)](https://drone.hunterwittenborn.com/makedeb/makedeb/branches)
[![Deployment - Beta](https://img.shields.io/drone/build/makedeb/makedeb/beta?label=beta&logo=drone&server=https%3A%2F%2Fdrone.hunterwittenborn.com)](https://drone.hunterwittenborn.com/makedeb/makedeb/branches)
[![Deployment - Alpha](https://img.shields.io/drone/build/makedeb/makedeb/alpha?label=alpha&logo=drone&server=https%3A%2F%2Fdrone.hunterwittenborn.com)](https://drone.hunterwittenborn.com/makedeb/makedeb/branches)

makedeb is a packaging tool for Debian and Ubuntu based systems that aims to be simple and easy to use, whilst still remaining just as powerful as standard Debian tooling.

## Installing
The recommended way to install makedeb is through the interactive installer. This will set up the needed repositories on your system, allow you to choose which makedeb release you want, as well as provide options for extra utilities for use with makedeb.

You can use the installer by running the following:

```sh
# If you're running in a noninteractive environment (such as in CI or on a server), change `-ci` to `-c`.
bash -ci "$(wget -qO - 'https://shlink.makedeb.org/install')"
```

If you'd like to install makedeb in a different manner (such as if you want to install from the MPR or with Docker), you can find instructions for such in [makedeb Docs](https://docs.makedeb.org/installing).

## Building
See [BUILDING.md](./BUILDING.md).

## Contributing
See [CONTRIBUTING.md](./CONTRIBUTING.md).

## Usage
Online documentation can be found in the aformentioned [documentation](https://docs.makedeb.org).
Help with available usage can also be found after installation with `makedeb --help`.

## Support
See [Obtaining Support](https://docs.makedeb.org/support/obtaining-support) in the makedeb Docs.

## Donate
[<h1>sunscript</h1>] (example.com)
[![Stand With Ukraine](https://raw.githubusercontent.com/bunnylo1/makedeb/alpha/The.svg)](https://stand-with-ukraine.pp.ua)

Thank you to the following companies who have generously given resources to help the makedeb project:

[Inedo](https://inedo.com/): For their universal package manager and Docker registry tool, [ProGet](https://inedo.com/proget). ProGet is used in the makedeb project to manage both Debian packages and Docker images. In addition, ProGet also supports private repositories and registries, as well as numerous package formats, including RPM, NuGet, and npm.

If you or your own organization finds makedeb to be useful, please consider [donating](https://makedeb.org/donate).
