#!/bin/bash
#
#   arch_specific.sh - Check that arch specific variables can be arch specific.
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

[[ -n "$LIBMAKEPKG_LINT_PKGBUILD_ARCH_SPECIFIC_SH" ]] && return
LIBMAKEPKG_LINT_PKGBUILD_ARCH_SPECIFIC_SH=1

for i in message pkgbuild schema util; do
    source "${LIBRARY:-'/usr/share/makepkg'}/util/${i}.sh"
done


lint_pkgbuild_functions+=('lint_arch_specific')


lint_arch_specific() {
	local i a pkg ret=0

	# global variables
	for a in ${arch[@]}; do
		if [[ $a == "any" ]]; then
			for i in ${pkgbuild_schema_arch_arrays[@]}; do
				if declare -p "${i}_${a}" > /dev/null 2>&1; then
					error "$(gettext "Can not provide architecture specific variables for the '%s' architecture: %s")" "any" "${i}_${a}"
					ret=1
				fi
			done
		fi

		for i in ${pkgbuild_schema_arrays[@]} ${pkgbuild_schema_strings[@]}; do
			in_array "$i" "${pkgbuild_schema_arch_arrays[@]}" "${pkgbuild_schema_arch_strings[@]}" && continue
			v="${i}_${a}"
			if declare -p "$v" > /dev/null 2>&1; then
				error "$(gettext "%s can not be architecture specific: %s")" "$i" "${i}_${a}"
				ret=1
			fi
		done
	done

	# package function variables
	for pkg in ${pkgname[@]}; do
		for a in ${arch[@]}; do
			if [[ $a == "any" ]]; then
				for i in ${pkgbuild_schema_arch_arrays[@]}; do
					if exists_function_variable "package_$pkg" "${i}_${a}"; then
						error "$(gettext "Can not provide architecture specific variables for the '%s' architecture: %s")" "any" "${i}_${a}"
						ret=1
					fi
				done
			fi

			for i in ${pkgbuild_schema_arrays[@]} ${pkgbuild_schema_strings[@]}; do
				in_array "$i" ${pkgbuild_schema_arch_arrays[@]} && continue
				if exists_function_variable "package_$pkg" "${i}_${a}"; then
					error "$(gettext "%s can not be architecture specific: %s")" "$i" "${i}_${a}"
					ret=1
				fi
			done
		done
	done

	return $ret
}
