#!/usr/bin/env bash
set -e

if [[ "${release_type}" == "stable" ]]; then
  rm AUR/makedeb/PKGBUILD
  cp src/PKGBUILDs/PKGBUILD_AUR_STABLE AUR/makedeb/PKGBUILD

elif [[ "${release_type}" == "alpha" ]]; then
  rm AUR/makedeb-alpha/PKGBUILD
  cp src/PKGBUILDs/PKGBUILD_AUR_ALPHA AUR/makedeb-alpha/PKGBUILD

else
  echo "Invalid option was set for 'release_type'"
  exit 1

fi
