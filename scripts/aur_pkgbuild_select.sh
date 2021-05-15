#!/usr/bin/env bash
set -e

rm */src/PKGBUILD
if [[ "${release_type}" == "stable" ]]; then
  wget "https://github.com/hwittenborn/makedeb/raw/alpha/src/PKGBUILDs/PKGBUILD_AUR_STABLE" -O */src/PKGBUILD

elif [[ "${release_type}" == "alpha" ]]; then
  wget "https://github.com/hwittenborn/makedeb/raw/alpha/src/PKGBUILDs/PKGBUILD_AUR_ALPHA" -O */src/PKGBUILD

fi
