# Building makedeb
The following instructions are for people who want to create their own packaging for makedeb. Normal users should follow the [standard installation instructions](./README.md/#installing).

## Cloning the makedeb repository.
First, you need to clone the makedeb repository:

```sh
git clone 'https://github.com/makedeb/makedeb'
```

Note that the `alpha` branch is the default branch that is cloned. If you are packaging makedeb for a production environment, you should checkout and use the `stable` branch:

```sh
git checkout stable
```

## Building makedeb
### Prerequisites
You need a few packages in order to build makedeb. These can change quickly as new releases are made, so you can find the list of build dependencies by running the following from the `PKGBUILD/` directory in your cloned repository (note that the listed dependencies will apply to that of Debian/Ubuntu - if you're packaging for a different distribution, you may need to change them):

```sh
TARGET=apt RELEASE=stable ./pkgbuild.sh | grep 'makedepends'
```

makedeb also has some runtime dependencies. You can find those by running the following in the same `PKGBUILD/` directory (these packages are also listed as their Debian/Ubuntu package names):

```sh
TARGET=apt RELEASE=stable ./pkgbuild.sh | grep '^depends'
```

### Building
After you have the needed build dependencies installed, run the following command from the root of your repository:

```sh
make prepare PKGVER="{pkgver}" RELEASE="{release}" TARGET="{target}"
make package DESTDIR="{pkgdir}" TARGET="{target}"
```

`{pkgver}` should contain the version of makedeb you're packaging, without the `v` prefix (so you would use `11.0.1` instead of `v11.0.1`)

`{release}` should be the branch you cloned (which should be `stable` if you checked out the `stable` branch previously in these instructions).

`{target}` should always be `apt` - using other values hasen't been tested and may result in a broken install.

Lastly, `{pkgdir}` should be the location you want to install makedeb to. Binaries automatically install into `/usr` after your specified prefix, so don't enter that as part of your directory.
