#!/usr/bin/env bash
set -e

# Import GPG Key.
echo "${debian_packaging_key}" | gpg --import-private-key

stable_conflicts=('makedeb-beta' 'makedeb-alpha')
beta_conflicts=('makedeb' 'makedeb-alpha')
alpha_conflicts=('makedeb' 'makedeb-beta')
conflicts="${release_type}_conflicts[@]"
conflicts="$(echo "${!conflicts}" | sed 's| |, |g')"

# Set package information.
sed -i "s|\$\${pkgname}|${pkgname}|" debian/control
sed -i "s|\$\${conflicts}|${conflicts}|" debian/control

# Build package.
git fetch
export NEEDED_VERSION="$(cat .data.json | jq -r '.current_pkgver')"
tar -cJf "../makedeb_${NEEDED_VERSION}.orig.tar.xz" .
debuild -S -sa -kkavplex@hunterwittenborn.com

cp files/dput.cf $HOME/.dput.cf
dput mentors "../${pkgname}_${NEEDED_VERSION}-1_source.changes"
