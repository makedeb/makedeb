#!/usr/bin/env bash
set -e

# Setup
git fetch

export VERSION=$(cat .data.json | jq -r '.current_pkgver')

# Tar current directory
tar -cJf ../makedeb_$VERSION.orig.tar.xz .

# Build makedeb.
debuild -us -uc
