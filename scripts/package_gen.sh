#!/usr/bin/env bash

echo "Setting PKGBUILD variables..."
if [[ "${1}" == "stable" ]]; then
  sed -i "s|custom release|stable release|g" src/PKGBUILD

elif [[ "${1}" == "alpha" ]]; then
  sed -i "s|pkgname=makedeb|pkgname=makedeb-alpha|g" src/PKGBUILD
  sed -i "s|custom release|alpha release|g" src/PKGBUILD

else
  sed -i "s|PKGBUILD_GEN_PKGNAME|makedeb|g" src/PKGBUILD
  sed -i "s|custom release|${1} release|g" src/PKGBUILD
fi

if [[ "${3}" == "aur" ]]; then
  echo "Setting up PKGBUILD for AUR release"
  echo \
'prepare() {
  bash "${srcdir}"/
}'
fi
