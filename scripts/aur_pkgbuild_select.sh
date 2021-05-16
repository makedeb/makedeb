#!/usr/bin/env bash
set -e

if [[ "${release_type}" == "stable" ]]; then
  rm aur_makedeb/PKGBUILD
  cp makedeb/src/PKGBUILDs/PKGBUILD_AUR_STABLE aur_makedeb/PKGBUILD

elif [[ "${release_type}" == "alpha" ]]; then
  rm aur_makedeb-alpha/PKGBUILD
  cp makedeb/src/PKGBUILDs/PKGBUILD_AUR_ALPHA aur_makedeb-alpha/PKGBUILD

else
  echo "Invalid option was set for 'release_type'"
  exit 1

fi
