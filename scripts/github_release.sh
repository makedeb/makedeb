#!/usr/bin/env bash

# Source PKGBUILD
source src/PKGBUILD

# Upload to GitHub Releases
curl -X POST \
     -H "Accept: application/vnd.github.v3+json" \
     
