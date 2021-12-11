#!/usr/bin/env bash
set -e


# Set package name
sed -i "s|\$\${pkgname}|${pkgname}|" debian/control

git fetch
export NEEDED_VERSION="$(cat .data.json | jq -r '.current_pkgver')"
tar -cJf "../makedeb_$NEEDED_VERSION.orig.tar.xz" .
debuild -us -uc
