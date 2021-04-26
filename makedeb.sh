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

#################
## OTHER STUFF ##
#################
files="$(ls)"
DIR="$(echo $PWD)"
srcdir="${DIR}/src"
pkgdir="${DIR}/pkg"
CURRENT_USER="$(id -u)"
BUILD_USER="$(whoami)"


#################
##  FUNCTIONS  ##
#################

help() {
echo "makedeb"
echo "Usage: makedeb [options]"
echo
echo "makedeb takes PKGBUILD files and compiles APT-installable archives."
echo
echo "Options:"
echo "  Items must be space-separated, i.e. '-I -F'"
echo
echo "  --help - bring up this help menu"
echo "  -I, --install - automatically install after building"
echo "  -F, --file, -p - specify a file to build from other than 'PKGBUILD'"
echo "  --convert[beta] - attempt to automatically convert Arch Linux dependencies to Debian dependencies"
echo
echo "Report bugs at https://github.com/hwittenborn/makedeb"
}

arg_check() {
  while true; do
    case "${1}" in
      --help)                                 help; exit 0 ;;
      -F | --file | -p)                       FILE=${2}; shift;;
      -I | --install)                         INSTALL="TRUE" ;;
      --convert)                              CONVERT="TRUE" ;;
      -*)                                     echo "Unknown option '${1}'"; exit 1 ;;
      "")                                     break ;;
    esac
    shift 1
    done
}

root_check() {
  if [[ "$(whoami)" == "root" ]]; then
    echo "Running makedeb as root is not allowed as it can cause irreversable damage to your system."
    exit 1
  fi
}

pkgsetup() {
  rm -r "${pkgdir}" &> /dev/null
  mkdir -p "${pkgdir}"/DEBIAN/
  touch "${pkgdir}"/DEBIAN/control
  }

install_makedeps() {
  if [[ "${new_makedepends}" != "" ]]; then
    echo "Checking make dependencies. One second..."
    for package in ${new_makedepends[@]}; do
      if [[ "$(apt list ${package} 2> /dev/null | sed 's/Listing...//g')" == "" ]]; then
        unknown_pkg+=" ${package}"
      fi
    done

    if [[ "${unknown_pkg}" != "" ]]; then
      echo "Couldn't find the following packages:${unknown_pkg[@]}"
      exit 1
    fi

    make_packages="$(apt list ${new_makedepends} 2> /dev/null | sed 's/Listing...//g' | grep -E "$(dpkg --print-architecture)|all" | grep -v "installed" | awk -F/ '{print $1}')"
    if [[ ${make_packages} != "" ]]; then
      echo "Installing make dependencies..."
      if ! sudo apt install ${make_packages}; then
        echo "Couldn't install packages."
        exit 1
      fi
    fi
  fi
}
rm_makedeps() {
  if [[ "${make_packages}" != "" ]]; then
    echo "Removing unneeded make dependencies..."
    sudo dpkg -r ${make_packages[@]} &> /dev/null
  fi
}

install_checkdeps() {
  if [[ "${new_checkdepends}" != "" ]]; then
    echo "Checking check dependencies. One second..."
    for package in ${new_checkdepends[@]}; do
      if [[ "$(apt list ${package} 2> /dev/null | sed 's/Listing...//g')" == "" ]]; then
        unknown_pkg+=" ${package}"
      fi
    done

    if [[ "${unknown_pkg}" != "" ]]; then
      echo "Couldn't find the following packages:${unknown_pkg[@]}"
      exit 1
    fi

    check_packages="$(apt list ${new_makedepends} 2> /dev/null | sed 's/Listing...//g' | grep -E "$(dpkg --print-architecture)|all" | grep -v "installed" | awk -F/ '{print $1}')"
    if [[ ${check_packages} != "" ]]; then
      echo "Installing check dependencies..."
      if ! sudo apt install ${check_packages}; then
        echo "Couldn't install packages."
        exit 1
      fi
    fi
  fi
}
rm_checkdeps() {
  if [[ "${check_packages}" != "" ]]; then
    echo "Removing unneeded check dependencies..."
    sudo dpkg -r ${check_packages[@]} &> /dev/null
  fi
}
export_control() {
  if [[ ${2} != "" ]]; then
    echo "${1} ${2}" >> "${pkgdir}"/DEBIAN/control
  fi
  }

convert_version() {
  if [[ ${epoch} == "" ]]; then
    export controlver="${pkgver}-${pkgrel}"
  else
    export controlver="${epoch}:${pkgver}-${pkgrel}"
  fi
  }

convert_arch() {
  if [[ ${arch} == "x86_64" ]]; then
    export makedeb_arch="amd64"
  elif [[ ${arch} == "armv7l" ]]; then
    export makedeb_arch="armhf"
  elif [[ ${arch} == "any" ]]; then
    export makedeb_arch="all"
  fi
  }

extract_pkg() {
  echo "Extracting ${pkgname}-${controlver}-${arch} package to pkgdir..."
  tar -xf "${pkgname}-${controlver}-${arch}.pkg.tar.zst" -C "${pkgdir}"
}

rm_dep_description() {
  NUM=0
  while [[ "${optdepends[$NUM]}" != "" ]]; do
    new_optdepends+=" $(echo ${optdepends[$NUM]} | awk -F: '{print $1}')"
    NUM=$(( ${NUM} + 1 ))
  done
  new_optdepends=$(echo ${new_optdepends[@]} | cut -c1-)

}

convert_deps() {
  rm_dep_description
  new_depends=${depends[@]}
  new_optdepends=${new_optdepends[@]}
  new_conflicts=${conflicts[@]}
  new_makedepends=${makedepends[@]}
  new_checkdepends=${checkdepends[@]}

  for pkg in $(cat /etc/makedeb/packages.db | sed 's/"//g'); do
    string1=$(echo "${pkg}" | awk -F= '{print $1}')
    string2="$(echo "${pkg}" | awk -F= '{print $2}')"

    new_depends=$(echo ${new_depends[@]} | sed "s/${string1}/${string2}/g")
    new_optdepends=$(echo ${new_optdepends[@]} | sed "s/${string1}/${string2}/g")
    new_conflicts=$(echo ${new_conflicts[@]} | sed "s/${string1}/${string2}/g")
    new_makedepends=$(echo ${new_makedepends[@]} | sed "s/${string1}/${string2}/g")
    new_checkdepends=$(echo ${new_checkdepends[@]} | sed "s/${string1}/${string2}/g")
  done

  new_depends=$(echo ${new_depends[@]} | sed 's/ /, /g')
  new_optdepends=$(echo ${new_optdepends[@]} | sed 's/ /, /g')
  new_conflicts=$(echo ${new_conflicts[@]} | sed 's/ /, /g')

}

####################
##  START SCRIPT  ##
####################
arg_check "${@}"
root_check

if [[ "${FILE}" == "PKGBUILD" ]]; then
  find PKGBUILD &> /dev/null || { help; exit 0; }
fi

source "${FILE}"
convert_deps

install_makedeps
install_checkdeps

echo "Running makepkg..."
makepkg -p "${FILE}" ${OPTIONS} || exit 1

rm_makedeps
rm_checkdeps

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
