#!/bin/bash
#
#   variable.sh - Check that variables are or are not arrays as appropriate
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

[[ -n "$LIBMAKEPKG_LINT_PKGBUILD_VARIABLE_SH" ]] && return
LIBMAKEPKG_LINT_PKGBUILD_VARIABLE_SH=1


for i in pkgbuild message schema; do
    source "${LIBRARY:-'/usr/share/makepkg'}/util/${i}.sh"
done


lint_pkgbuild_functions+=('lint_variable')


lint_variable() {
	local i a pkg out bad ret=0

	# global variables
	for i in ${pkgbuild_schema_arrays[@]}; do
		if declare -p $i > /dev/null 2>&1; then
			if ! is_array $i; then
				error "$(gettext "%s should be an array")" "$i"
				ret=1
			fi
		fi
	done

	for a in ${arch[@]}; do
		[[ $a == "any" ]] && continue

		for i in ${pkgbuild_schema_arch_arrays[@]}; do
			if declare -p "${i}_${a}" > /dev/null 2>&1; then
				if ! is_array ${i}_${a}; then
					error "$(gettext "%s should be an array")" "${i}_${a}"
					ret=1
				fi
			fi
		done
	done

	for i in ${pkgbuild_schema_strings[@]}; do
		if declare -p "$i" > /dev/null 2>&1; then
			if is_array $i; then
				error "$(gettext "%s should not be an array")" "$i"
				ret=1
			fi
		fi
	done

	# package function variables
	for pkg in ${pkgname[@]}; do
		for i in ${pkgbuild_schema_arrays[@]}; do
			if extract_function_variable "package_$pkg" $i 0 out; then
				error "$(gettext "%s should be an array")" "$i"
				ret=1
			fi
		done

		for a in ${arch[@]}; do
			[[ $a == "any" ]] && continue

			for i in ${pkgbuild_schema_arch_arrays[@]}; do
				if extract_function_variable "package_$pkg" "${i}_${a}" 0 out; then
					error "$(gettext "%s should be an array")" "${i}_${a}"
					ret=1
				fi
			done
		done

		for i in ${pkgbuild_schema_strings[@]}; do
			if extract_function_variable "package_$pkg" $i 1 out; then
				error "$(gettext "%s should not be an array")" "$i"
				ret=1
			fi
		done
	done

	return $ret
}
