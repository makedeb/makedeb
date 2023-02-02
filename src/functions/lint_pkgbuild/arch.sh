#!/bin/bash
#
#   arch.sh - Check the 'arch' array conforms to requirements.
#
#   Copyright (c) 2014-2021 Pacman Development Team <pacman-dev@archlinux.org>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

[[ -n "$LIBMAKEPKG_LINT_PKGBUILD_ARCH_SH" ]] && return
LIBMAKEPKG_LINT_PKGBUILD_ARCH_SH=1

LIBRARY=${LIBRARY:-'/usr/share/makepkg'}

source "$LIBRARY/util/message.sh"
source "$LIBRARY/util/pkgbuild.sh"


lint_pkgbuild_functions+=('lint_arch')


lint_arch() {
	local a name list ret=0

	if in_array "any" "${arch[@]}" || in_array "all" "${arch[@]}"; then
		if (( ${#arch[@]} == 1 )); then
			return 0;
		else
			error "$(gettext "Can not use '%s' architecture with other architectures")" "any"
			return 1;
		fi
	fi

	for a in "${arch[@]}"; do
		if [[ $a = *[![:alnum:]_]* ]]; then
			error "$(gettext "%s contains invalid characters: '%s'")" \
					'arch' "${a//[[:alnum:]_]}"
			ret=1
		fi
	done

	if (( ! IGNOREARCH )) && ! in_array "${MAKEDEB_DPKG_ARCHITECTURE}" "${arch[@]}"; then
		# If the user provides an Arch Linux style architecture (from the output of 'uname -p' it's seeming), allow such to pass the architecture check, but encourage the use of the Debian style.
		if in_array "${CARCH}" "${arch[@]}"; then
			! (( "${INFAKEROOT}" )) && warning "$(gettext "Detected invalid architecture '%s'. Please use '%s' instead.")" "${CARCH}" "${MAKEDEB_DPKG_ARCHITECTURE}"
			arch+=("${MAKEDEB_DPKG_ARCHITECTURE}")
		else
			error "$(gettext "%s is not available for the '%s' architecture.")" "$_pkgbase" "${MAKEDEB_DPKG_ARCHITECTURE}"
			return 1
		fi
	fi

	for name in "${pkgname[@]}"; do
		get_pkgbuild_attribute "$name" 'arch' 1 list
		if [[ $list && $list != 'any' && $list != 'all' ]] && ! in_array "${MAKEDEB_DPKG_ARCHITECTURE}" "${list[@]}"; then
			if (( ! IGNOREARCH )); then
				error "$(gettext "%s is not available for the '%s' architecture.")" "$name" "${MAKEDEB_DPKG_ARCHITECTURE}"
				ret=1
			fi
		fi
	done

	# Make sure the user didn't provide an architecture-overridable item as an item in 'arch=()' (see https://github.com/makedeb/makedeb/issues/92).
	for pkgbuild_variable in "${pkgbuild_schema_arch_arrays[@]}"; do
		for a in "${arch[@]}"; do
			if echo "${a}" | grep -q "${pkgbuild_variable}"; then
				error "$(gettext "Architecture '%s' cannot contain PKGBUILD variable reference '%s'.")" "${a}" "${pkgbuild_variable}"
				ret=1
			fi
		done
	done

	return $ret
}
