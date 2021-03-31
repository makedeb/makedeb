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
echo "  -U, --user - specifies a user to build as when running as root"
echo
echo "  --skip-rootcheck - skip checking of root privileges"
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
      -U | --user)                            BUILD_USER="${2}"; shift 1 ;;

      --skip-rootcheck)                        SKIP_ROOTCHECK="TRUE" ;;
      -*)                                     echo "Unknown option '${1}'"; exit 1 ;;
      "")                                     break ;;
    esac
    shift 1
    done
}

root_check() {
  ## CHECKS WHEN RUNNING AS ROOT ##
	if [[ "${CURRENT_USER}" == "0" ]] && [[ ${BUILD_USER} == "root" ]]; then
		echo "A user other than 'root' must be specified to build as when running mpm as root"
		exit 1

	elif [[ "${CURRENT_USER}" == "0" ]] && ! id ${BUILD_USER} &> /dev/null; then
		echo "User '${BUILD_USER}' doesn't exist"
		exit 1

	## OBTAIN ROOT PRIVILEGES WHEN NOT RUNNING AS ROOT ##
	else
		echo "Obtaining root privileges..."
		sudo echo &> /dev/null
		if [[ ${?} != "0" ]]; then
	 		echo "Couldn't get root privileges"
	 		exit 1
 		fi
	fi
}

pkgsetup() {
  rm -r "${pkgdir}" &> /dev/null
  mkdir -p "${pkgdir}"/DEBIAN/
  touch "${pkgdir}"/DEBIAN/control
  }

install_makedeps() {
  if [[ "${new_makedepends}" != "" ]]; then
    echo "[#] Installing make dependencies..."
    local packages="$(apt list ${new_makedepends} 2> /dev/null | sed 's/Listing...//g' | grep -v "installed" | awk -F/ '{print $1}')"
    sudo apt install ${packages}
  fi
}
rm_makedeps() {
  if [[ "${new_makedepends}" != "" ]]; then
    echo "[#] Removing unneeded make dependencies..."
    sudo dpkg -r ${new_makedepends[@]} &> /dev/null
  fi
}

install_checkdeps() {
  if [[ "${new_checkdepends}" != "" ]]; then
    echo "[#] Installing check dependencies..."
    local packages="$(apt list ${new_checkdepends} 2> /dev/null | sed 's/Listing...//g' | grep -v "installed" | awk -F/ '{print $1}')"
    sudo apt install ${packages}
  fi
}
rm_checkdeps() {
  if [[ "${new_checkdepends}" != "" ]]; then
    echo "[#] Removing unneeded check dependencies..."
    sudo dpkg -r ${new_checkdepends[@]} &> /dev/null
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
  echo "[#] Extracting ${pkgname}-${controlver}-${arch} package to pkgdir..."
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

if [[ ${SKIP_ROOTCHECK} != "TRUE" ]]; then
  root_check
fi

source "${FILE}"
convert_deps

install_makedeps
install_checkdeps

echo "[#] Running makepkg..."
sudo -u "${BUILD_USER}" makepkg -p "${FILE}" ${OPTIONS} || exit 1

rm_makedeps
rm_checkdeps

pkgsetup
convert_version
convert_arch

extract_pkg

echo "[#] Generating control file..."
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

echo "[#] Cleaning up..."
sudo rm "${pkgdir}/.BUILDINFO"
sudo rm "${pkgdir}/.MTREE"
sudo rm "${pkgdir}/.PKGINFO"

field() {
  cat "${pkgdir}/DEBIAN/control" | grep "${1}:" | awk -F": " '{print $2}'
}

debname=$( echo "$(field Package)_$(field Version)_$(field Architecture)" )

find "${DIR}/${debname}.deb" &> /dev/null
if [[ ${?} == "0" ]]; then
  echo "[#] Built package detected. Removing..."
  rm "${DIR}/${debname}.deb"
fi

echo "[#] Building package..."
dpkg -b "${pkgdir}" >> /dev/null
dpkg-name $(basename "${pkgdir}").deb >> /dev/null
echo "[#] Built package..."

if [[ ${INSTALL} == "TRUE" ]]; then
  sudo apt install "${DIR}/${debname}.deb"
fi
