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

# Values to expose to makepkg.
declare -rx PKGEXT='.pkg.tar.zst'

# Other variables.
declare INSTALL='FALSE'
declare FILE='PKGBUILD'
declare PREBUILT='false'
declare package_convert="false"
declare hide_control_output=0

declare makedeb_package_version="$${MAKEDEB_VERSION}"
declare makedeb_release_type="$${MAKEDEB_RELEASE}"
declare makedeb_release_target="$${MAKEDEB_TARGET}"

if [[ "${makedeb_release_target}" == "local" || "${makedeb_release_target}" == "mpr" ]]; then
	declare target_os="debian"
elif [[ "${makedeb_release_target}" == "arch" ]]; then
	declare target_os="arch"
fi

declare makepkg_package_name="makedeb-makepkg"
declare MAKEDEB_UTILS_DIR="./utils/" # COMP_RM
declare makedeb_utils_dir="${MAKEDEB_UTILS_DIR:-/usr/share/makedeb/utils/}"

cd ./
declare files="$(ls)"
declare DIR="$(echo $PWD)"
declare srcdir="${DIR}/src/"
declare pkgdir="${DIR}/pkg/"


####################
##  BEGIN SCRIPT  ##
####################
# Get makepkg message syntax
source "/usr/share/${makepkg_package_name}/util/message.sh"
colorize

# Debug logs in case a function is                       # COMP_RM
# stopping something from working during testing         # COMP_RM
for i in $(find functions/); do                          # COMP_RM
                                                         # COMP_RM
  if ! [[ -d "${i}" ]]; then                             # COMP_RM
    if [[ "${in_fakeroot}" != "true" ]]; then            # COMP_RM
      msg "Sourcing functions from ${i}..."              # COMP_RM
    fi                                                   # COMP_RM
                                                         # COMP_RM
    source <(cat "${i}")                                 # COMP_RM
  fi                                                     # COMP_RM
done                                                     # COMP_RM
                                                         # COMP_RM
[[ "${in_fakeroot}" != "true" ]] && echo                 # COMP_RM

trap_codes

if [[ "${in_fakeroot}" ]]; then
  set -- "${@}"
fi

# Hide errors and warning from the argument check when in the fakeroot
# environment, as they'll already have been processed.
if [[ "${in_fakeroot}" == "true" ]]; then
  arg_check "${@}" 2> /dev/null
else
  arg_check "${@}"
fi

# Jump into fakeroot_build() if we're triggering the script from inside a fakeroot in the build stage
if [[ "${in_fakeroot}" == "true" ]]; then
  fakeroot_build
  exit "${?}"
fi

root_check

find "${FILE}" &> /dev/null || { error "Couldn't find ${FILE}"; exit 1; }

source "${FILE}"
pkgbuild_check
"${makepkg_package_name}" --format-makedeb --lint -p "${FILE}"

convert_version
check_architecture
check_distro_dependencies
remove_dependency_description
generate_prefix_fields

# Set pkgbase
pkgbase="${pkgbase:-${pkgname[0]}}"

# Check if we're printing a generated control file
if (( "${print_control}" )); then
  generate_control "./${FILE}" "/dev/stdout"
  exit "${?}"
fi

msg "Making package: ${pkgbase} ${makedeb_package_version} ($(date '+%a %d %b %Y %T %p %Z'))..."
find "${pkgdir}" &> /dev/null && rm "${pkgdir}" -rf

# Check build dependencies.
if [[ "${skip_dependency_checks}" == "true" ]]; then
  warning "Skipping dependency checks."
else
  msg "Checking build dependencies..."
  check_missing_dependencies

  if [[ "${install_dependencies}" == "true" ]]; then
    install_missing_dependencies
  else
    verify_no_missing_dependencies
  fi
fi

run_dependency_conversion

msg "Entering fakeroot environment..."

"${makepkg_package_name}" --format-makedeb --nodeps -p "${FILE}" "${makepkg_args[@]}"

# We keep tihs as a normal string (instead of an array) so that we can access
# the variable inside of subshells. <https://stackoverflow.com/a/5564589>
declare makedeb_apt_package_version="$(echo "${makedeb_package_version}" | sed 's|^[^:].*:||g')"

# Create .deb files
in_fakeroot="true" fakeroot -- bash ${BASH_SOURCE[0]} "${@}"

# Run cleanup tasks
msg "Cleaning up..."
rm -rf dependency_deb

# Print finished build message.
msg "Finished making: ${pkgbase} ${makedeb_package_version} ($(date '+%a %d %b %Y %T %p %Z'))."

# Remove build dependencies
if [[ "${remove_dependencies}" == "true" ]]; then
  remove_installed_dependencies
fi

# Install built package
if [[ "${target_os}" == "debian" ]] && [[ ${INSTALL} == "TRUE" ]]; then
  declare apt_install_list=()

  for i in "${pkgname[@]}"; do
    apt_installation_list+=("./${i}_${makedeb_apt_package_version}_${MAKEDEB_CARCH}.deb")
  done

  apt_installation_string="$(echo "${pkgname[@]}" | sed 's| |, |g')"
  msg "Installing ${apt_installation_string}..."
  sudo apt-get reinstall "${apt_args[@]}" -- "${apt_installation_list[@]}"

  if (( "${makedeb_args["as-deps"]}" )); then
    sudo apt-mark auto -- "${pkgname[@]}" 1> /dev/null
  fi
fi
