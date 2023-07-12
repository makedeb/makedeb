#!/bin/bash
#
#   package_function_variable.sh - Check variables inside the package function.
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

[[ -n "$LIBMAKEPKG_LINT_PKGBUILD_PACKAGE_FUNCTION_VARIABLE_SH" ]] && return
LIBMAKEPKG_LINT_PKGBUILD_PACKAGE_FUNCTION_VARIABLE_SH=1

for i in message pkgbuild schema util; do
    source "${LIBRARY:-'/usr/share/makepkg'}/util/${i}.sh"
done


lint_pkgbuild_functions+=('lint_package_function_variable')


lint_package_function_variable() {
	local i a pkg ret=0

	# package function variables
	for pkg in ${pkgname[@]}; do
		for a in ${arch[@]}; do
			[[ $a == "any" ]] && continue

			for i in ${pkgbuild_schema_arrays[@]} ${pkgbuild_schema_strings[@]}; do
				in_array "$i" ${pkgbuild_schema_package_overrides[@]} && continue
				if exists_function_variable "package_$pkg" "${i}_${a}"; then
					error "$(gettext "%s can not be set inside a package function")" "${i}_${a}"
					ret=1
				fi
			done
		done

		for i in ${pkgbuild_schema_arrays[@]} ${pkgbuild_schema_strings[@]}; do
			in_array "$i" ${pkgbuild_schema_package_overrides[@]} && continue
			if exists_function_variable "package_$pkg" "$i"; then
				error "$(gettext "%s can not be set inside a package function")" "$i"
				ret=1
			fi
		done
	done

	return $ret
}
