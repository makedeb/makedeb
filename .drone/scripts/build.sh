#!/usr/bin/env bash
set -exuo pipefail
sudo chown 'makedeb:makedeb' ./ -R

# Get variables
pkgver="$(cat 'src/PKGBUILD' | grep '^pkgver=' | awk -F '=' '{print $2}')"

# Copy PKGBUILD
rm 'src/PKGBUILD'
cp "PKGBUILDs/LOCAL/${release_type^^}.PKGBUILD" "src/PKGBUILD"

# Configure PKGBUILD
sed -i "s|pkgver={pkgver}|pkgver=${pkgver}|" 'src/PKGBUILD'

# Build makedeb
cd src
./makedeb.sh --sync-deps --no-confirm
