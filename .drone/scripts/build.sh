#!/usr/bin/env bash
set -e
git fetch
sudo chown 'makedeb:makedeb' ./ -R

# Build makedeb.
export TARGET=local
export RELEASE="${release_type}"

cd PKGBUILD/
./pkgbuild.sh > PKGBUILD

makedeb -s --no-confirm
