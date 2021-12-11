#!/usr/bin/env bash
set -e

# Get current package version
version="$(cat .data.json | jq -r '.current_pkgver + "-" + .current_pkgrel')"

# Update debian version
DEBVERSION="$(cat debian/changelog | cut -f2 -d" " - | grep "(" | cut -f2 -d"(" | cut -f1 -d")")"

# Setup env vars needed
DEBFULLNAME="Leo Puvilland"
DEBEMAIL="leo@craftcat.dev"

rm debian/changelog

if [ $version != $DEBVERSION ]; then
  dch --create --package makedeb -D unstable -v $version "Initial release (Closes: #998039)."
fi

# Set package name
sed -i "s|\$\${pkgname}|${pkgname}| debian/control

git fetch
export NEEDED_VERSION="$(cat .data.json | jq -r '.current_pkgver')"
tar -cJf "../makedeb_$NEEDED_VERSION.orig.tar.xz" .
debuild -us -uc
