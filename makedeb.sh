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
echo "  --help - bring up this help menu"
echo "  --install - automatically install after building"
echo "  --skip-download - skip downloading of files"
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

  ## CLEANUP TASKS ##
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
  if [[ ${depends} != "" ]]; then
    echo "Depends:" >> "${pkgdir}"/DEBIAN/control
    sed -i "/Depends/s/$/ ${depends}/" "${pkgdir}"/DEBIAN/control
    for package in ${depends[@]:1}; do
      sed -i "/Depends/s/$/, ${package}/" "${pkgdir}"/DEBIAN/control
    done
  fi
  }

pull_sources() {
if [[ ${DOWNLOAD} == "TRUE" ]]; then
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
else
  echo "[#] Skipping download ..."
  fi
  }

hashsum_check() {
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

run_functions() {
    type ${1} &> /dev/null
    if [[ ${?} == "0" ]]; then
    echo "[#] Running '${1}' function ..."
    ${1}
    fi
  }

build_package() {
  echo "[#] Building package ${pkgname}_${pkgver}_${arch} ..."
  dpkg -b "${pkgdir}" >> /dev/null
  dpkg-name "${pkgdir}.deb" >> /dev/null
  }

check_build() {
  find "${srcdir}/.pkg_built" &> /dev/null
  if [[ ${?} == "0" ]]; then
    echo "[#] Package functions already ran ..."
    build_package
    echo "[#] Package ${pkgname}_${pkgver}_${arch} sucessfully built."
    exit 0
  fi
  }

####################
##  START SCRIPT  ##
####################

config_setup
while true; do
  case "${1}" in
  --help)                                 help; exit 0 ;;
  --install)                              INSTALL="TRUE" ;;
  --skip-download)                        DOWNLOAD="FALSE" ;;
  "")                                     break ;;
  esac
  shift
  done
root_check
setup
import_pkgbuild
sanity_check
check_build

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
# convert_dependencies
echo "" >> "${pkgdir}"/DEBIAN/control

## PULL AND VERIFY SOURCES ##
mkdir -p "${srcdir}"
cd "${srcdir}"

pull_sources
hashsum_check
exit 0

## RUN PREPARE, BUILD, and PACKAGE FUNCTIONS ##
cd "${srcdir}"
run_functions prepare
run_functions build
cd "${DIR}"
run_functions package
touch "${srcdir}/.pkg_built"

## BUILD AND INSTALL PACKAGE ##
build_package
if [[ ${INSTALL} == "TRUE" ]]; then
  echo "[#] Installing ${pkgname}_${pkgver}_${arch}.deb"
  sudo apt install "${pkgdir}/${pkgname}_${pkgver}_${arch}.deb"
fi
