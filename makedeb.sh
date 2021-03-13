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
    export controlver="${pkgver}-${pkgrel}"
  else
    export controlver="${epoch}:${pkgver}-${pkgrel}"
  fi
  }

convert_arch() {
  if [[ ${arch} == "x86_64" ]]; then
    export arch="amd64"
  fi
  }

convert_dependencies() {
  if [[ ${3} != "" ]]; then
    echo "${1}" >> "${pkgdir}"/DEBIAN/control
    sed -i "/${1}/s/$/ $(echo ${3} | awk -F: '{print $1}')/" "${pkgdir}"/DEBIAN/control
    for package in $(eval "echo \${$2[@]:1}" | awk -F: '{print $1}'); do
      sed -i "/${1}/s/$/, $(echo ${package})/" "${pkgdir}"/DEBIAN/control
    done
  fi
  }

url_convert() {
  echo ${1} | sed "s/%20/ /g"
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
      echo "[#] Downloading '$(url_convert `basename $string2`)' to '${string1}' ..."
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
      echo "[#] Downloading " $(url_convert `basename "${pkg}"`) " ..."
        wget -q --show-progress "${pkg}"
      else
        echo "[#] Copying " "`basename ${pkg}`" " to source directory"
        cp "${DIR}"/"`basename ${pkg}`" .
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

      while [[ ${source_file} -le ${source_total} ]]; do
        ## CHECK IF DOWNLOADED FILE WAS RENAMED AND GET HASHES ##
        recorded_hash=$(eval "echo \${$do_hash[$source_file]}" | awk '{print $1}')

        if [[ $( echo ${source[$source_file]} | awk -F:: '{print $2}' ) != "" ]]; then
          current_hash=$( ${do_hash::-1} "$( echo ${source[$source_file]} | awk -F:: '{print $1}' )" | awk '{print $1}')
        else
          current_hash=$( ${do_hash::-1} "$(url_convert `basename ${source[$source_file]}`)" | awk '{print $1}' )
        fi

        ## CHECK HASHES ##
        if [[ $(eval "echo \${$do_hash[$source_file]}") == "SKIP" ]]; then
          echo "[#] Skipping ${do_hash::-1} integrity check on $(url_convert `basename ${source[$source_file]}`)."
        elif [[ ${current_hash} != "${recorded_hash}" ]]; then
          echo "[!] "$(url_convert `basename ${source[$source_file]}`)" failed the integrity check on ${do_hash}."
          exit 1
        else
          echo "[#] "$(url_convert `basename ${source[$source_file]}`)" passed the integrity check on ${do_hash}."
        fi
        source_file=$(( ${source_file} + 1 ))
      done
    fi
  done
}

extract_sources() {
  for file in $(ls | grep .tar.xz); do
    echo "[#] Extracting ${file} ..."
    tar -xf $file
    done
  for file in $(ls | grep .deb); do
    echo "[#] Extracting ${file} ..."
    ar xv ${file}
    done
}

do_function() {
  check_function=$(printf "$(type ${1} 2> /dev/null | sed "1,3d" | sed "$ d")")
  if [[ ${check_function} != "" ]]; then
    "${2}" &> /dev/null
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
export_control "Version:" "${controlver}"
export_control "Architecture:" "${arch}"
export_control "Maintainer:" "${MAINTAINER}"
convert_dependencies "Depends:" "depends" "${depends}"
convert_dependencies "Recommends:" "optdepends" "${optdepends}"
convert_dependencies "Conflicts:" "conflicts" "${conflicts}"
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
extract_sources

## MAKE PACKAGE ##
if [[ "${BUILD}" == "TRUE" ]]; then
  cd "${srcdir}"
  do_function prepare "set -e"
  do_function pkgver "set -e"
  do_function build "set -e"
  do_function check "set -e"
  do_function package
fi

## BUILD AND INSTALL PACKAGE ##
build_package
