#!/usr/bin/env bash
set -e

stable_conflicts=('makedeb-beta' 'makedeb-alpha')
beta_conflicts=('makedeb' 'makedeb-alpha')
alpha_conflicts=('makedeb' 'makedeb-beta')
conflicts="${release_type}_conflicts[@]"
conflicts="${!conflicts}"

# Set package information.
sed -i "s|\$\${pkgname}|${pkgname}|" debian/control
sed -i "s|\$\${conflicts}|${conflicts}|" debian/control

# Build package.
git fetch
export NEEDED_VERSION="$(cat .data.json | jq -r '.current_pkgver')"
tar -cJf "../makedeb_${NEEDED_VERSION}.orig.tar.xz" .
debuild -us -uc

cp "../makedeb_${NEEDED_VERSION}-1_all.deb" ./
