#!/usr/bin/env bash

# Copyright 2020-2021 Hunter Wittenborn <hunter@hunterwittenborn.com>
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

set -Ee

####################
## DEFAULT VALUES ##
####################
declare LC_ALL="C"
declare INSTALL='FALSE'
declare FILE='PKGBUILD'
declare PREBUILT='false'
declare package_convert="false"

#################
## OTHER STUFF ##
#################
declare makedeb_package_version="git"
declare makedeb_release_type="git"
declare target_os="debian"
declare makepkg_package_name="makedeb-makepkg"

cd ./
export files="$(ls)"
export DIR="$(echo $PWD)"
export srcdir="${DIR}/src/"
export pkgdir="${DIR}/pkg/"


####################
##  BEGIN SCRIPT  ##
####################
# Get makepkg message syntax
source "/usr/share/${makepkg_package_name}/util/message.sh"
colorize

# Debug logs in case a function is                       # REMOVE AT PACKAGING
# stopping something from working during testing         # REMOVE AT PACKAGING
for i in $(find functions/); do                          # REMOVE AT PACKAGING
                                                         # REMOVE AT PACKAGING
  if ! [[ -d "${i}" ]]; then                             # REMOVE AT PACKAGING
    if [[ "${in_fakeroot}" != "true" ]]; then            # REMOVE AT PACKAGING
      msg "Sourcing functions from ${i}..."              # REMOVE AT PACKAGING
    fi                                                   # REMOVE AT PACKAGING
                                                         # REMOVE AT PACKAGING
    source <(cat "${i}")                                 # REMOVE AT PACKAGING
  fi                                                     # REMOVE AT PACKAGING
done                                                     # REMOVE AT PACKAGING
[[ "${in_fakeroot}" != "true" ]] && echo                 # REMOVE AT PACKAGING

trap_codes

if [[ "${in_fakeroot}" ]]; then
  eval set -- ${@}
fi

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

# Set pkgbase
pkgbase="${pkgbase:-${pkgname[0]}}"

# Check if we're printing a generated control file
if (( "${print_control}" )); then
  # We want to put all values from 'pkgname' under a single 'Package' field.
  # This isn't syntactically correct by Debian's policy for binary control
  # fields, but it prevents us from having to repeat everything twice for
  # multiple packages.

  check_distro_dependencies
  remove_dependency_description
  generate_optdepends_fields
  run_dependency_conversion

  generate_control "./${FILE}"
  exit "${?}"
fi

msg "Making package: ${pkgbase} ${makedeb_package_version} ($(date '+%a %d %b %Y %T %p %Z'))..."
convert_arch

find "${pkgdir}" &> /dev/null && rm "${pkgdir}" -rf

# Check build dependencies
if [[ "${target_os}" == "debian" ]]; then
  msg "Checking build dependencies..."

  check_distro_dependencies

  # Combine depends, makedepends and checkdepends all into depends.
  eval dependency_packages=("$(echo -n ${depends[@]@Q} ${makedepends[@]@Q} ${checkdepends[@]@Q} | \
                         sed 's| |\n|g' | \
                         sort -u | \
                         tr -t '\n' ' ')")

  eval depends=(${dependency_packages[@]@Q})

  remove_dependency_description
  run_dependency_conversion

  if [[ "${install_dependencies}" == "true" ]]; then
    check_dependencies
    install_depends
  elif [[ "${skip_dependency_checks}" != "true" ]]; then
    check_dependencies
    verify_dependencies
  fi
fi

msg "Entering fakeroot environment..."

"${makepkg_package_name}" --format-makedeb --noarchive -p "${FILE}" ${makepkg_options}

# We keep tihs as a normal string (instead of an array) so that we can access
# the variable inside of subshells. <https://stackoverflow.com/a/5564589>
declare makedeb_apt_package_version="$(echo "${makedeb_package_version}" | sed 's|^[^:].*:||g')"

# Create .deb files
in_fakeroot="true" fakeroot -- bash ${BASH_SOURCE[0]} ${@@Q}

# Run cleanup tasks
msg "Cleaning up..."
run_cleanup

# Print finished build message.
msg "Finished making: ${pkgbase} ${makedeb_package_version} ($(date '+%a %d %b %Y %T %p %Z'))."

# Remove build dependencies
if [[ "${target_os}" == "debian" && "${install_dependencies}" == "true" && "${remove_dependencies}" == "true" ]]; then
  remove_dependencies
fi

# Install built package
if [[ "${target_os}" == "debian" ]] && [[ ${INSTALL} == "TRUE" ]]; then
  convert_version &> /dev/null

  for i in ${pkgname[@]}; do
    declare apt_install+=("./${i}_${makedeb_apt_package_version}_${makedeb_arch}.deb")
  done

  msg "Installing $(echo "${apt_install}" | sed 's|^\./||g' | sed 's| | ,|g' | rev | sed 's|, ||' | rev)..."
  sudo apt-get reinstall -- ${apt_install[@]}
fi
