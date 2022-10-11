#!/usr/bin/env bash
set -e

git fetch
sudo chown 'makedeb:makedeb' ./ -R

# Build makedeb.
TARGET=apt RELEASE="${release_type}" LOCAL=1 PKGBUILD/pkgbuild.sh > src/PKGBUILD
cd src
./main.sh -s --no-confirm
mv makedeb*.deb ../