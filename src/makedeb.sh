#!/usr/bin/env bash
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
export LC_ALL="C"
export INSTALL='FALSE'
export FILE='PKGBUILD'
export PREBUILT='false'
export package_convert="false"

export FUNCTIONS_DIR="./"
export DATABASE_DIR="/usr/share/makedeb-db/"

#################
## OTHER STUFF ##
#################
export makedeb_package_version="git"
export target_os="debian"

cd ./
export files="$(ls)"
export DIR="$(echo $PWD)"
export srcdir="${DIR}/src/"
export pkgdir="${DIR}/pkg/"


####################
##  BEGIN SCRIPT  ##
####################
# Get makepkg message syntax
source "/usr/share/makepkg/util/message.sh"
colorize

# Debug logs in case a function is                       # REMOVE AT PACKAGING
# stopping something from working during testing         # REMOVE AT PACKAGING
for i in $(find functions/); do                          # REMOVE AT PACKAGING
    if ! [[ -d "${i}" ]]; then                           # REMOVE AT PACKAGING
        if [[ "${in_fakeroot}" != "true" ]]; then        # REMOVE AT PACKAGING
            msg "Sourcing functions from ${i}..."        # REMOVE AT PACKAGING
        fi                                               # REMOVE AT PACKAGING
        source <(cat "${i}")                             # REMOVE AT PACKAGING
    fi                                                   # REMOVE AT PACKAGING
done                                                     # REMOVE AT PACKAGING
[[ "${in_fakeroot}" != "true" ]] && echo                 # REMOVE AT PACKAGING
                                                         # REMOVE AT PACKAGING
trap_codes

# Argument Check
arg_number="$#"
number=1
while [[ "${number}" -le "${arg_number}" ]]; do
    split_args "$(eval echo \${$number})"
    number="$(( "${number}" + 1 ))"
done

arg_check


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

msg "Making package: ${pkgbase:-$pkgname} ${pkgbuild_version} ($(date))..."
convert_arch

if [[ "${distro_packages}" == "true" ]]; then
    check_distro_dependencies
fi

find "${pkgdir}" &> /dev/null && rm "${pkgdir}" -rf

remove_dependency_description
run_dependency_conversion --nocommas

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

msg "Running makepkg..."
{ makepkg -p "${FILE}" ${makepkg_options}; } | grep -Ev 'Making package|Checking.*dependencies|fakeroot environment|Finished making|\.PKGINFO|\.BUILDINFO|\.MTREE'

rm "${pkgdir}" -r

export in_fakeroot="true"
fakeroot -- bash ${BASH_SOURCE[0]} ${@}

if [[ "${target_os}" == "debian" && "${install_dependencies}" == "true" ]]; then
remove_depends make
remove_depends check
fi

if [[ "${target_os}" == "debian" ]] && [[ ${INSTALL} == "TRUE" ]]; then

for i in ${pkgname[@]}; do
        apt_install+="./${i}_${built_archive_version}_${makedeb_arch}.deb "
    done

    msg "Installing $(echo "${apt_install}" | sed 's|\./||g' | sed 's| | ,|g' | rev | sed 's|, ||' | rev)..."
    sudo apt install ${apt_install}
fi
