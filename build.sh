#!/usr/bin/env bash
srcdir="$(pwd)/build/src"
mkdir ${srcdir} -p


. ./PKGBUILD/TEMPLATE.PKGBUILD

ln -s ../PKGBUILD/TEMPLATE.PKGBUILD ./build/PKGBUILD
ln -s ../../ ./build/src/"${pkgname}"

cd ./build
bash ../src/main.sh --noextract --nodeps ${@}
cd ..
