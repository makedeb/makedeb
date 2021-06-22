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
set -o pipefail

####################
## DEFAULT VALUES ##
####################
export INSTALL='FALSE'
export FILE='PKGBUILD'
export PREBUILT='false'
export package_convert="false"

export FUNCTIONS_DIR="./"
export DATABASE_DIR="/usr/share/makedeb-db/"

#################
## OTHER STUFF ##
#################
export package_version="git"
export target_os="debian"

cd ./
export files="$(ls)"
export DIR="$(echo $PWD)"
export srcdir="${DIR}/src/"
export pkgdir="${DIR}/pkg/"


####################
##  BEGIN SCRIPT  ##
####################
source <(cat functions/*.sh)      # REMOVE AT PACKAGING
source <(cat functions/*/*.sh)    # REMOVE AT PACKAGING

# Get makepkg message syntax
source "/usr/share/makepkg/util/message.sh"
colorize

trap_codes
arg_check "${@}"

# Jump into fakeroot_build() if we're triggering the script from inside a fakeroot in the build stage
if [[ "${in_fakeroot}" == "true" ]]; then
    fakeroot_build
    exit ${?}
fi

root_check

find "${FILE}" &> /dev/null || { error "Couldn't find ${FILE}"; exit 1; }

source "${FILE}"
pkgbuild_check

convert_version
msg "Making package: ${pkgbase-$pkgname} ${globalver} ($(date))..."

if [[ "${prebuilt_pkgname}" != "" ]]; then
    msg "Replacing value of \$pkgname with ${prebuilt_pkgname} in build file..."
    sed -i "s|pkgname=.*|# &\npkgname=${prebuilt_pkgname}|" "${FILE}"
    source "${FILE}"
fi

find "${pkgdir}" &> /dev/null && rm "${pkgdir}" -rf

remove_dependency_description
run_dependency_conversion --nocommas

if [[ "${PREBUILT}" == "false" ]]; then
    # 1. Only run if on Debian, as distros like Arch don't have APT, and when
    # '-s' option is passed.
    # 2. Same as 1, but only run when '-d' is passed.
    if [[ "${target_os}" == "debian" && "${install_dependencies}" == "true" ]]; then
        install_depends new_depends ""
        install_depends new_makedepends make
        install_depends new_checkdepends check
    elif [[ "${target_os}" == "debian" && "${skip_dependency_checks}" != "true" ]]; then
      verify_dependencies
    fi

    msg "Entering fakeroot environment..."
    export in_fakeroot="true"
    fakeroot -- bash ${BASH_SOURCE[0]} ${@}

    if [[ "${target_os}" == "debian" && "${install_dependencies}" == "true" ]]; then
    remove_depends make
    remove_depends check
    fi
else
    unset depends optdepends conflicts provides
    package="${pkgname[0]}"

    if [[ "${pkgname[1]}" != "" ]]; then
        if [[ "${prebuilt_pkgname}" == "" ]]; then
            warning "--pkgname wasn't supplied, assuming '${pkgname[0]}'"
        else
            package="${prebuilt_pkgname}"
        fi
    fi

    msg "Entering fakeroot environment..."
    export in_fakeroot="true"
    fakeroot -- bash ${BASH_SOURCE[0]} ${@}
fi

[[ "${target_os}" == "debian" ]] && if [[ ${INSTALL} == "TRUE" ]]; then
    for i in ${debname_install}; do
        apt_install+="${PWD}/${i}.deb "
    done

    msg "Installing $(echo "${apt_install}" | sed "s|${PWD}/||g" | sed 's| | ,|g')..."
    sudo apt install ${apt_install}
fi
