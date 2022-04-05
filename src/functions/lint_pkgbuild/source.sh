#!/bin/bash
#
#   source.sh - Check the 'source' array is not sparse.
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

[[ -n "$LIBMAKEPKG_LINT_PKGBUILD_SOURCE_SH" ]] && return
LIBMAKEPKG_LINT_PKGBUILD_SOURCE_SH=1

LIBRARY=${LIBRARY:-'/usr/share/makepkg'}

source "$LIBRARY/util/message.sh"


lint_pkgbuild_functions+=('lint_source')


lint_source() {
	local idx=("${!source[@]}")
	local source_vars=()
	local hash_types=()
	local source
	local distro
	local arch_name
	local hash_var

	if (( ${#source[*]} > 0 && (${idx[@]: -1} + 1) != ${#source[*]} )); then
		error "$(gettext "Sparse arrays are not allowed for source")"
		return 1
	fi

	# Get a list of all source variables.
	in_array source "${env_keys[@]}" && source_vars+=('source')
	mapfile -O "${#source_vars[@]}" -t source_vars < <(printf '%s\n' "${env_keys[@]}" | grep -E '.+_source$')

	for arch_name in "${arch[@]}"; do
		mapfile -O "${#source_vars[@]}" -t source_vars < <(printf '%s\n' "${env_keys[@]}" | grep "^source_${arch_name}\$")
		mapfile -O "${#source_vars[@]}" -t source_vars < <(printf '%s\n' "${env_keys[@]}" | grep -E ".+_source_${arch_name}\$")
	done

	# Get a list of hashtypes that are used in the PKGBUILD.
	for source in "${source_vars[@]}"; do
		distro="$(echo "${source}" | sed 's|source.*||' | sed 's|_$||')"
		arch_name="$(echo "${source}" | sed 's|.*source||' | sed 's|^_||')"

		for hashtype in "${known_hash_algos[@]}"; do
			if [[ -n "${distro}" && -n "${arch_name}" ]]; then
				hash_var="${distro}_${hashtype}sums_${arch_name}"
			elif [[ -n "${distro}" ]]; then
				hash_var="${distro}_${hashtype}sums"
			elif [[ -n "${arch_name}" ]]; then
				hash_var="${hashtype}sums_${arch_name}"
			else
				hash_var="${hashtype}sums"
			fi
			
			if in_array "${hash_var}" "${env_keys[@]}"; then
				hash_types+=("${hashtype}")
			fi
		done
	done
	
	mapfile -t hash_types < <(printf '%s\n' "${hash_types[@]}" | sort -u)
}
