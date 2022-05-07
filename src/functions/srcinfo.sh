#!/bin/bash
#
#   srcinfo.sh - functions for writing .SRCINFO files
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

[[ -n "$LIBMAKEPKG_SRCINFO_SH" ]] && return
LIBMAKEPKG_SRCINFO_SH=1

LIBRARY=${LIBRARY:-'/usr/share/makepkg'}

source "$LIBRARY/util/pkgbuild.sh"
source "$LIBRARY/util/schema.sh"

srcinfo_write_value() {
	if [[ "${2-x}" == 'x' ]]; then
		return 1
	fi

	printf '%s = %s\n' "$1" "$2"
}

write_srcinfo() {
	local string
	local array_item
	local current_array_item
	local item
	local matches
	local match
	
	srcinfo_write_value 'generated-by' 'makedeb'

	# 'pkgname' is special, as it can be both a string and an array.
	# Likewise, it's not in the schema_strings or schema_arrays lists.
	for item in "${pkgname[@]}"; do
		srcinfo_write_value pkgname "${item}"
	done

	for string in "${pkgbuild_schema_strings[@]}"; do
		in_array "${string}" "${env_keys[@]}" && srcinfo_write_value "${string}" "${!string}"
	done

	for array_item in "${pkgbuild_schema_arrays[@]}"; do
		! in_array "${array_item}" "${env_keys[@]}" && continue

		current_array_item="${array_item}[@]"
		current_array_item=("${!current_array_item}")

		for item in "${current_array_item[@]}"; do
			srcinfo_write_value "${array_item}" "${item}"
		done
	done

	for string in "${pkgbuild_schema_arch_strings[@]}"; do
		mapfile -t matches < <(printf '%s\n' "${env_keys[@]}" | grep "${string}" | grep -v "^${string}\$" | head -c -1)

		for match in "${matches[@]}"; do
			srcinfo_write_value "${match}" "${!match}"
		done
	done

	for array_item in "${pkgbuild_schema_arch_arrays[@]}"; do
		mapfile -t matches < <(printf '%s\n' "${env_keys[@]}" | grep "${array_item}" | grep -v "^${array_item}\$" | head -c -1)

		for match in "${matches[@]}"; do
			current_array_item="${match}[@]"
			current_array_item=("${!current_array_item}")

			for item in "${current_array_item[@]}"; do
				srcinfo_write_value "${match}" "${item}"
			done
		done
	done
}
