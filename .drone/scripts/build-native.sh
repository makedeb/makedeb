#!/usr/bin/env bash
set -e

git fetch
export VERSION=$(cat .data.json | jq -r '.current_pkgver')
tar -cJf ../makedeb_$VERSION.orig.tar.xz .
debuild -us -uc
