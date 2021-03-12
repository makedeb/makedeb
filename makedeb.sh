#!/bin/bash

################################################
##  Copyright Hunter Wittenborn 2020          ##
##                                            ##
##  PKGBUILD, makepkg and related assets are  ##
##  properties of their respective owners.    ##
##                                            ##
##  This program is free software; you can    ##
##  redistribute it and/or modify it under    ##
##  the terms of the GNU General Public       ##
##  License v3.0                              ##
################################################


####################
## DEFAULT VALUES ##
####################

DOWNLOAD='TRUE'
INSTALL='FALSE'
BUILD='TRUE'


#################
##  FUNCTIONS  ##
#################

root_check() {
  if [[ $(whoami) == "root" ]]; then
    echo "[!] Running makedeb as root is not allowed."
    exit 1
    fi
    }

help() {
echo "makedeb v0.1.1"
echo "Usage: makedeb [options]"
echo ""
echo "makedeb takes PKGBUILD files and compiles APT-installable archives."
echo ""
echo "Options:"
echo "  Items must be space-separated, i.e. '-I -S'"
echo ""
echo "  --help - bring up this help menu"
echo "  -I, --install - automatically install after building"
echo "  -B, --build-only - skip functions, and go straight to build the .deb archive"
echo "  -S, --skip-download - skip downloading of files"
echo ""
echo "A config file is located in '~/.config/makedeb/config'."
echo "Options for this file:"
echo "    MAINTAINER - set a maintainer for built packages"
echo ""
echo "Report bugs at https://github.com/hwittenborn/makedeb"
}

setup() {
  DIR="$(echo ${PWD})"
  ## DEFAULT VALUES FOR SOME VARIABLES ##
  pkgdir="${DIR}/pkg"
  srcdir="${DIR}/src"
}

cleanup() {
  rm "${DIR}"/makedeb.log &> /dev/null
  rm "${pkgdir}" -R &> /dev/null
  }

import_pkgbuild() {
  find_pkgbuild=$(find PKGBUILD &> /dev/null; echo ${?})

  if [[ ${find_pkgbuild} == "0" ]]; then
    source PKGBUILD
  else
    echo "[!] Couldn't find a PKGBUILD."
    echo "[!] Make sure a PKGBUILD is located in the current directory."
    exit 1
  fi
  }

sanity_check() {
  for check in pkgname pkgver pkgrel pkgdesc arch source; do
    if [[ "(eval \${$check})" == "" ]]; then
      echo "[!] '${check}' is not set in the PKGBUILD"
      if [[ ${check} == "source" ]]; then
        exit 1
        fi
      fi
  done
  }

config_setup() {
  find ~/.config/makedeb/config &> /dev/null
  if [[ "$?" != "0" ]]; then
    mkdir -p ~/.config/makedeb/ &> /dev/null
    touch ~/.config/makedeb/config
  fi

  . ~/.config/makedeb/config
  }

config_import() {
  source ~/.config/makedeb/config
  }

pkgsetup() {
  rm -r "${pkgdir}" &> /dev/null
  mkdir -p "${pkgdir}"/DEBIAN/
  touch "${pkgdir}"/DEBIAN/control
  }

export_control() {
  if [[ {$2} != "" ]]; then
    echo "${1} ${2}" >> "${pkgdir}"/DEBIAN/control
  fi
  }

convert_version() {
  if [[ ${epoch} == "" ]]; then
    export pkgver="${pkgver}-${pkgrel}"
  else
    export pkgver="${epoch}:${pkgver}-${pkgrel}"
  fi
  }

convert_arch() {
  if [[ ${arch} == "x86_64" ]]; then
    export arch="amd64"
  fi
  }

convert_dependencies() {
  if [[ ${2} != "" ]]; then
    echo "${1}:" >> "${pkgdir}"/DEBIAN/control
    sed -i "/${1}/s/$/ ${2}/" "${pkgdir}"/DEBIAN/control
    for package in ${depends[@]:1}; do
      sed -i "/${1}/s/$/, ${package}/" "${pkgdir}"/DEBIAN/control
    done
  fi
  }

pull_sources() {
  for pkg in ${source[@]}; do

    echo "${pkg}" | grep "::" &> /dev/null
    if [[ ${?} == 0 ]]; then

      ## OBTAIN TWO STRINGS FROM SOURCE ##
      string1=$(echo ${pkg} | awk -F:: '{print $1}')
      string2=$(echo ${pkg} | awk -F:: '{print $2}')

      ## CHECK FOR URL IN SECOND STRING ##
      echo "${string2}" | grep "http" &> /dev/null
      if [[ ${?} == 0 ]]; then
      echo "[#] Downloading '$(basename $string2)' to '${string1}' ..."
        wget -q --show-progress ${string2}
        echo "[#] Moving '$(basename $string2)' to '${string1}' ..."
        mv $(basename $string2) ${string1}
      else
        echo "[#] Copying "'${DIR}"/"${string2}'" to "'${string1}'" ..."
        cp "'${DIR}'"/"'${string2}'" "'${string1}'"
      fi
    else

      ## CHECK FOR URL IN SINGLE STRING ##
      echo "${pkg}" | grep "http" &> /dev/null
      if [[ ${?} == 0 ]]; then
      echo "[#] Downloading '$(basename $pkg)' ..."
        wget -q --show-progress ${pkg}
      else
        echo "[#] Copying '${pkg}' to source directory"
        cp "${DIR}"/"${pkg}" .
      fi
    fi
  done
}

integrity_check() {
  for do_hash in md5sums sha256sums sha1sums sha224sums sha384sums sha512sums b2sums; do
    ## CHECK IF HASHES ARE SET FOR EACH TYPE ##
    if [[ ${!do_hash} != "" ]]; then
      source_file="0"
      source_total=$(( $(echo ${source[@]} | wc -w) -1 ))
      recorded_hash=${!do_hash[$source_file]}
      current_hash=$( ${do_hash::-1} $(basename ${source[$source_file]}) | awk '{print $1}')

      if [[ ${!do_hash} == "SKIP" ]]; then
        echo "[#] Skipping ${do_hash::-1} check on '$(basename ${source[$source_file]})'."
      elif [[ ${current_hash} != ${recorded_hash} ]]; then
        echo "[!] '$(basename ${source[$source_file]})' failed the integrity check on ${do_hash}."
        exit 1
      else
        echo "[#] '$(basename ${source[$source_file]})' passed the integrity check on ${do_hash}."
      fi
    fi
  done
}

do_function() {
  check_function=$(printf "$(type ${1} 2> /dev/null | sed "1,3d" | sed "$ d")")
  if [[ ${check_function} != "" ]]; then
    echo "[#] Running ${1}() ..."
    ${1}
  fi
}

build_package() {
  rm "${DIR}/${pkgdir}.deb" &> /dev/null
  rm "${DIR}/${pkgname}_${pkgver}_${arch}.deb" &> /dev/null
  echo "[#] Building '${pkgname}_${pkgver}_${arch}.deb' ..."
  dpkg -b "${pkgdir}" >> /dev/null
  dpkg-name "${pkgdir}.deb" >> /dev/null
  echo "[#] Built '${pkgname}_${pkgver}_${arch}.deb'"

  if [[ "${INSTALL}" == "TRUE" ]]; then
    echo "[#] Installing ''${pkgname}_${pkgver}_${arch}.deb'"
    sudo apt install "${pkgdir}/${pkgname}_${pkgver}_${arch}.deb"
  fi
  }

####################
##  START SCRIPT  ##
####################

config_setup
while true; do
  case "${1}" in
  --help)                                 help; exit 0 ;;
  -I | --install)                              INSTALL="TRUE" ;;
  -B | --build-only)                         BUILD="FALSE" ;;
  -S | --skip-download)                        DOWNLOAD="FALSE" ;;
  "")                                     break ;;
  esac
  shift
  done
root_check
setup
import_pkgbuild
if [[ ${BUILD} == "FALSE" ]]; then
  build_package
  exit 0
fi
cleanup
sanity_check

echo "[#] Preparing ..."
pkgsetup
convert_version
convert_arch
export_control "Package:" "${pkgname}"
export_control "Description:" "${pkgdesc}"
export_control "Source:" "${source}"
export_control "Version:" "${pkgver}"
export_control "Architecture:" "${arch}"
export_control "Maintainer:" "${MAINTAINER}"
convert_dependencies "Depends:" "${depends}"
convert_dependencies "Recommends:" "${optdepends}"
convert_dependencies "Conflicts:" "${conflicts}"
echo "" >> "${pkgdir}"/DEBIAN/control

## PULL AND VERIFY SOURCES ##
if [[ ${DOWNLOAD} == "TRUE" ]]; then
  rm -r "${srcdir}" &> /dev/null
  mkdir -p "${srcdir}"
  cd "${srcdir}"

  pull_sources
else
  cd "${srcdir}"
  echo "[#] Skipping file downloads ..."
fi
integrity_check

## MAKE PACKAGE ##
if [[ "${BUILD}" == "TRUE" ]]; then
  cd "${srcdir}"
  do_function prepare
  do_function pkgver
  do_function build
  do_function check
  do_function package
fi

## BUILD AND INSTALL PACKAGE ##
build_package
