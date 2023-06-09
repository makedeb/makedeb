#!/usr/bin/env bash
curdir="$(pwd)"
blddir="${curdir}/build"
srcdir="${blddir}/src"
script="${blddir}"/PKGBUILD
mkdir -p "${srcdir}"

bash "${curdir}/scripts/pkgbuild.sh" > "${script}"

. "${blddir}"/PKGBUILD
ln -s ../../ "${srcdir}"/"${pkgname}"
cd ./build
bash ../src/main.sh "${@}"
cd ..
