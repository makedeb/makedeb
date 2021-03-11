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
  
  ## CLEANUP TASKS ##
  rm ${DIR}/makedeb.log &> /dev/null
  rm ${pkgdir} -R &> /dev/null
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
    echo ${1} | grep "http" &> /dev/null
    if [[ ${?} == "0" ]]; then
      echo "[#] Pulling $(basename ${1}) ..."
      wget ${1} -q --show-progress
    else
      echo "[#] Copying ${1} to source directory ..."
      cp ${DIR}/${1} "${srcdir}"
    fi
  }
  
source_files() {
  for source_check in ${source[@]}; do
    (find "${srcdir}/$(basename ${source_check})" &> /dev/null)
    if [[ ${?} != "0" ]]; then
    pull_sources ${source_check}
    fi
    done
    }
    

count_sums() {
  sum_count=$(($(echo ${sha256sums} | wc -w) - 1))
  }

verify_sources() {
  sum_current="0"
  while [[ ${sum_current} -le ${sum_count} ]]; do
    echo "[#] Checking integrety of $(basename ${source[${sum_current}]}) ..."
    current_sum=$(sha256sum ${srcdir}/$(basename ${source[${sum_current}]}) | awk '{print $1}')
    if [[ ${current_sum} != ${sha256sums[${sum_current}]} ]]; then
      echo "[!] $(basename ${source[${sum_current}]}) failed the integrety check."
      echo "[!] Try deleting the file from '${srcdir}/$(basename ${source[${sum_current}]})' and run makedeb again"
      exit 1
    else
      echo "[#] Passed."
    sum_current=$((${sum_current} + 1))
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

source_files
verify_sources

## RUN PREPARE, BUILD, and PACKAGE FUNCTIONS ##
cd "${srcdir}"
run_functions prepare
run_functions build
cd "${DIR}"
run_functions package

## BUILD PACKAGE ##
echo "[#] Building package ..."
dpkg -b "${pkgdir}"
