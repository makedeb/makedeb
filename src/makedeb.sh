#!/bin/bash
# Copyright 2020 Hunter Wittenborn <git@hunterwittenborn.me>
#
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
#
# PKGBUILD, makepkg and related assets are properties of their
# respective owners.

####################
## DEFAULT VALUES ##
####################
INSTALL='FALSE'
FILE='PKGBUILD'
FUNCTIONS_DIR="./"

#################
## OTHER STUFF ##
#################
files="$(ls)"
DIR="$(echo $PWD)"
srcdir="${DIR}/src"
pkgdir="${DIR}/pkg"


####################
##  BEGIN SCRIPT  ##
####################
source <(cat "${FUNCTIONS_DIR}"/functions/*.sh)
source <(cat "${FUNCTIONS_DIR}"/functions/*/*.sh)

arg_check "${@}"
root_check

if [[ "${FILE}" == "PKGBUILD" ]]; then
  find PKGBUILD &> /dev/null || { help; exit 0; }
fi

source "${FILE}"
convert_deps

install_depends new_makedepends make
install_depends new_checkdepends check

echo "Running makepkg..."
makepkg -p "${FILE}" ${OPTIONS} || exit 1

remove_depends make
remove_depends check

pkgsetup
convert_version
convert_arch

extract_pkg

echo "Generating control file..."
export_control "Package:" "${pkgname}"
export_control "Description:" "${pkgdesc}"
export_control "Source:" "${source}"
export_control "Version:" "${controlver}"

arch=$(cat "${pkgdir}"/.PKGINFO | grep "arch" | awk -F" = " '{print $2}')
export_control "Architecture:" "${makedeb_arch}"
export_control "Maintainer:" "$(cat ${FILE} | grep '\# Maintainer\:' | sed 's/# Maintainer: //')"
export_control "Depends:" "${new_depends[@]}"
export_control "Suggests:" "${new_optdepends[@]}"
export_control "Conflicts:" "${new_conflicts[@]}"

echo "" >> "${pkgdir}"/DEBIAN/control

echo "Cleaning up..."
rm -f "${pkgdir}/.BUILDINFO"
rm -f "${pkgdir}/.MTREE"
rm -f "${pkgdir}/.PKGINFO"

field() {
  cat "${pkgdir}/DEBIAN/control" | grep "${1}:" | awk -F": " '{print $2}'
}

debname=$( echo "$(field Package)_$(field Version)_$(field Architecture)" )

find "${DIR}/${debname}.deb" &> /dev/null
if [[ ${?} == "0" ]]; then
  echo "Built package detected. Removing..."
  rm "${DIR}/${debname}.deb"
fi

echo "Building package..."
dpkg -b "${pkgdir}" >> /dev/null
dpkg-name $(basename "${pkgdir}").deb >> /dev/null
echo "Built package..."

if [[ ${INSTALL} == "TRUE" ]]; then
  sudo apt install "${DIR}/${debname}.deb"
fi
