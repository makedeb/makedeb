#!/usr/bin/env bash
set -e

sudo chown 'makedeb:makedeb' ../ -R

# Import GPG Key.
echo "${debian_packaging_key}" | gpg --import

conflicts=('makedeb-beta' 'makedeb-alpha')
conflicts="$(echo "${conflicts[@]}" | sed 's| |, |g')"

# Set package information.
sed -i "s|\$\${pkgname}|${pkgname}|" debian/control
sed -i "s|\$\${conflicts}|${conflicts}|" debian/control

# Build package.
git fetch
export NEEDED_VERSION="$(cat .data.json | jq -r '.current_pkgver')"
tar -cJf "../makedeb_${NEEDED_VERSION}.orig.tar.xz" .
debuild -S -sa -kkavplex@hunterwittenborn.com

cp .drone/files/dput.cf $HOME/.dput.cf
dput mentors "../makedeb_${NEEDED_VERSION}-1_source.changes"
