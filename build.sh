#!/usr/bin/env bash
srcdir="$(pwd)/build/src"
mkdir ${srcdir} -p

commit="$(git rev-parse HEAD)"

cp ./PKGBUILD/PKGBUILD ./build/PKGBUILD

. ./PKGBUILD/PKGBUILD

prepare

. ./package.sh

cd ./build
bash ./src/build/usr/bin/"${pkgname}" --nobuild --noextract --nodeps ${@}
cd ..
