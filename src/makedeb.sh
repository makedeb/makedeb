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
INSTALL='FALSE'
FILE='PKGBUILD'
PREBUILT='FALSE'
package_convert="false"

FUNCTIONS_DIR="./"
DATABASE_DIR="/usr/share/makedeb-db/"

#################
## OTHER STUFF ##
#################
package_version="git"
target_os="debian"

files="$(ls)"
DIR="$(echo $PWD)"
srcdir="${DIR}/src/"
pkgdir="${DIR}/pkg/"


####################
##  BEGIN SCRIPT  ##
####################
source <(cat functions/*.sh)      # REMOVE AT PACKAGING
source <(cat functions/*/*.sh)    # REMOVE AT PACKAGING

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

    echo "Running makepkg..."
    makepkg -p "${FILE}" ${makepkg_options}
    rm *.pkg.tar.zst &> /dev/null

    if [[ "${target_os}" == "debian" && "${install_dependencies}" == "true" ]]; then
        remove_depends make
        remove_depends check
    fi

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

[[ "${target_os}" == "debian" ]] && if [[ ${INSTALL} == "TRUE" ]]; then
    for i in ${debname_install}; do
        apt_install+="${PWD}/${i}.deb "
    done

    sudo apt install ${apt_install}
fi
