#!/bin/bash

################################################
##      Copyright Hunter Wittenborn 2020      ##
##                                            ##
##  PKGBUILD, makepkg and related assets are  ##
##   properties of their respective owners.   ##
##                                            ##
##       ** SCRIPT STARTS AT LINE 136 **      ##
################################################


#################
##  FUNCTIONS  ##
#################

root_check() {
  if [[ $(whoami) == "root" ]]; then
    echo "[!] Running makedeb as root is not allowed."
    exit 1
    fi
    }

setup() {
  DIR="$(echo ${PWD})"
  ## DEFAULT VALUES FOR SOME VARIABLES ##
  pkgdir="${DIR}/pkg"
  srcdir="${DIR}/src"
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
  for package in ${source[@]}; do
    echo ${package} | grep "http" &> /dev/null
    if [[ ${?} == "0" ]]; then
      echo "[#] Pulling $(basename ${package}) ..."
      wget ${package} -q --show-progress
    else
      echo "[#] Copying ${package} to source directory ..."
      cp ${DIR}/${package} "${srcdir}"
    fi
  done
  }

count_sums() {
  sum_count=$(($(echo ${sha256sums} | wc -w) - 1))
  }

verify_sources() {
  sum_current="0"
  while [[ ${sum_current} -le ${sum_count} ]]; do
    echo "[#] Checking integrety of ${source[${sum_current}]} ..."
    current_sum=$(sha256sum ${srcdir}/$(basename ${source[${sum_current}]}) | awk '{print $1}')
    if [[ ${current_sum} != ${sha256sums[${sum_current}]} ]]; then
      echo "[!] ${source[${sum_current}]}) failed the integrety check."
      exit 1
    else
      echo "[#] Passed."
    sum_current=$((${sum_current} + 1))
    fi
  done
  }
    

####################
##  START SCRIPT  ##
####################

root_check
setup
import_pkgbuild
sanity_check
config_setup

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
convert_dependencies
echo "" >> "${pkgdir}"/DEBIAN/control

## PULL AND VERIFY SOURCES ##
mkdir -p "${srcdir}"
cd "${srcdir}"

pull_sources
verify_sources

## RUN PREPARE, BUILD, and PACKAGE FUNCTIONS ##
echo "[#] Running prepare function ..."
prepare

echo "[#] Running package function ..."
package

