#!/bin/bash
# Copyright 2020-2021 Hunter Wittenborn <hunter@hunterwittenborn.com>
##
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
##
# makepkg and it's related assets are properties of their respective owners.

set -e
####################
## DEFAULT VALUES ##
####################
INSTALL='FALSE'
FILE='PKGBUILD'
PREBUILT='FALSE'
package_convert="false"

FUNCTIONS_DIR="./"
DATABASE_DIR="/usr/lib/makedeb-db/"

#################
## OTHER STUFF ##
#################
files="$(ls)"
DIR="$(echo $PWD)"
srcdir="${DIR}/src/"
pkgdir="${DIR}/pkg/"


####################
##  BEGIN SCRIPT  ##
####################
source <(cat "${FUNCTIONS_DIR}"/functions/*.sh)
source <(cat "${FUNCTIONS_DIR}"/functions/*/*.sh)

trap_codes
arg_check "${@}"
root_check

find "${FILE}" &> /dev/null || { echo "Couldn't find ${FILE}"; exit 1; }

source "${FILE}"
pkgbuild_check

if [[ "${prebuilt_pkgname}" != "" ]]; then
    echo "Replacing value of \$pkgname with ${prebuilt_pkgname} in build file..."
    sed -i "s|pkgname=.*|# &\npkgname=${prebuilt_pkgname}|" "${FILE}"
    source "${FILE}"
fi

find "${pkgdir}" &> /dev/null && rm "${pkgdir}" -rf

remove_dependency_description
run_dependency_conversion --nocommas

if [[ "${PREBUILT}" == "FALSE" ]]; then
  install_depends new_depends ""
  install_depends new_makedepends make
  install_depends new_checkdepends check

  echo "Running makepkg..."
  makepkg -p "${FILE}" ${OPTIONS} || exit 1
  rm *.pkg.tar.zst &> /dev/null

  remove_depends make
  remove_depends check

  pkgsetup
  for package in ${pkgname[@]}; do
    unset depends optdepends conflicts provides
    cd "${pkgdir}"/"${package}"

    get_variables
    remove_dependency_description
    run_dependency_conversion
    convert_version
    generate_control

    echo "Cleaning up..."
    rm -f ".BUILDINFO"
    rm -f ".MTREE"
    rm -f ".PKGINFO"

    field() {
      cat "DEBIAN/control" | grep "${1}:" | awk -F": " '{print $2}'
    }

    debname=$( echo "$(field Package)_$(field Version)_$(field Architecture)" )
    debname_install+=" ${debname}"

    cd ..
    if find ../"${debname}.deb" &> /dev/null; then
      echo "Built package detected. Removing..."
      rm ../"${debname}.deb"
    fi

    echo "Building ${pkgname}..."
    dpkg -b "${pkgdir}"/"${package}" >> /dev/null
    mv "${package}".deb ../
    dpkg-name ../"${package}".deb >> /dev/null
    echo "Built ${pkgname}"

    cd ..
  done
else
  unset depends optdepends conflicts provides
  package="${pkgname[0]}"

  if [[ "${pkgname[1]}" != "" ]]; then
    if [[ "${prebuilt_pkgname}" == "" ]]; then
      echo "--pkgname wasn't supplied, assuming '${pkgname[0]}'"
    else
      package="${prebuilt_pkgname}"
    fi
  fi

  mkdir -p "${pkgdir}"/"${package}"/DEBIAN/

  convert_version
  tar -xf "${package}"-"${controlver}"-"${arch}".pkg.tar.zst -C "${pkgdir}"/"${package}" --force-local
  cd "${pkgdir}"/"${package}"

  get_variables
  remove_dependency_description
  run_dependency_conversion
  generate_control

  echo "Cleaning up..."
  rm -f ".BUILDINFO"
  rm -f ".MTREE"
  rm -f ".PKGINFO"

  field() {
    cat "DEBIAN/control" | grep "${1}:" | awk -F": " '{print $2}'
  }

  debname=$( echo "$(field Package)_$(field Version)_$(field Architecture)" )
  debname_install+=" ${debname}"

  cd ..
  if find ../"${debname}.deb" &> /dev/null; then
    echo "Built package detected. Removing..."
    rm ../"${debname}.deb"
  fi

  echo "Building ${package}..."
  dpkg -b "${pkgdir}"/"${package}" >> /dev/null
  mv "${package}".deb ../
  dpkg-name ../"${package}".deb >> /dev/null
  echo "Built ${package}"
fi

if [[ ${INSTALL} == "TRUE" ]]; then
  for i in ${debname_install}; do
    # Run 'cd' in case someone nasty decides to manually change the value of the $PWD variable
    apt_install+="$(cd; echo ${PWD})/${i}.deb "
  done

  sudo apt install ${apt_install}
fi
