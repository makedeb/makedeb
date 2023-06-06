#!/usr/bin/env bash
srcdir="$(pwd)/build/src"
mkdir -p ${srcdir}
. ./PKGBUILD/TEMPLATE.PKGBUILD
ln -s ../PKGBUILD/TEMPLATE.PKGBUILD ./build/PKGBUILD
ln -s ../../ ./build/src/"${pkgname}"
cd ./build
bash ../src/main.sh "${@}"
cd ..
