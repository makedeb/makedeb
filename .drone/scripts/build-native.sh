#!/usr/bin/env bash
set -e

stable_conflicts=('makedeb-beta' 'makedeb-alpha')
beta_conflicts=('makedeb' 'makedeb-alpha')
alpha_conflicts=('makedeb' 'makedeb-beta')
conflicts="${release_type}_conflicts[@]"
conflicts="$(echo "${!conflicts}" | sed 's| |, |g')"

# Set package information.
sed -i "s|\$\${pkgname}|${pkgname}|" debian/control
sed -i "s|\$\${conflicts}|${conflicts}|" debian/control

# Install needed dependencies.
needed_deps="$(cat debian/control  | grep '^Build-Depends:' | sed 's|^Build-Depends: ||')"
sudo apt-get satisfy "${needed_deps}" -y

# Build package.
git fetch
pkgver="$(cat .data.json | jq -r '.current_pkgver')"
pkgrel="$(cat .data.json | jq -r ".current_pkgrel_${release_type}")"
sed -i "s|\$\${pkgver}|${pkgver}-${pkgrel}|" debian/changelog
tar -cJf "../makedeb_${pkgver}.orig.tar.xz" .
debuild -us -uc

cp "../${pkgname}_${pkgver}-${pkgrel}_all.deb" ./
