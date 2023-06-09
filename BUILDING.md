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

In addition, [just](https://github.com/casey/just) needs to be installed in order to build.

makedeb also has some runtime dependencies. You can find those by running the following in the same `PKGBUILD/` directory (these packages are also listed as their Debian/Ubuntu package names):

```sh
TARGET=apt RELEASE=stable ./pkgbuild.sh | grep '^depends'
```

### Building
After you have the needed build dependencies installed, run the following command from the root of your repository:

```sh
VERSION='{version}' RELEASE='{release}' TARGET='{target}' FILESYSTEM_PREFIX='{filesystem_prefix}' BUILD_COMMIT='{build_commit}' DPKG_ARCHITECTURE='{arch}' just build DESTDIR='{destdir}' make build
```

#### `{version}`
`{version}` should contain the version of makedeb you're packaging, without the `v` prefix (so you would use `11.0.1-2` instead of `v11.0.1-2`).

#### `{release}`
`{release}` should be the branch you cloned (which should be `stable` if you checked out the `stable` branch previously in these instructions).

#### `{target}`
`{target}` should always be `apt` or `mpr` - using other values hasn't been tested and may result in a broken install.

#### `{filesystem_prefix}`
`{filesystem_prefix}` is an optional global filesystem prefix makedeb uses to get needed files from in the built package.

I.e. if all files for makedeb were located under `/container/makedeb` (so you'd have locations like `/container/makedeb/usr/bin/makedeb`), then you need to set this value. If ommitted, it defaults to being blank.

In most cases you don't need to set this.

#### `{build_commit}`
`{build_commit}` is the commit that the built package is marked as being built from. In most cases you can just set this to the output of `$(git rev-parse HEAD)`.

#### `{arch}`
The architecture (it being one from the output of `dpkg --print-architecture`) to build makedeb for. Currently supported values are `amd64`, `i386`, `arm64`, and `armhf`. If you need to build makedeb for an architecture outside of those, please open an issue.

#### `{destdir}`
The directory prefix to place built files into.
