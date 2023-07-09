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

source "${LIBRARY:-'/usr/share/makepkg'}/util/message.sh"

lint_pkgbuild_functions+=('lint_source')

# Check that each source entry ('source' itself, as well as those with distro and/or architecture extensions) conforms to our requirements.
lint_source() {
	local idx=("${!source[@]}")
	local source_vars=()
	local hash_types=()
	local hash_variables=()
	local ret=0
	local src
	local distro
	local arch_name
	local hash_var
	local hash_values
	local source_values
	local a

	if (( ${#source[*]} > 0 && (${idx[@]: -1} + 1) != ${#source[*]} )); then
		error "$(gettext "Sparse arrays are not allowed for source")"
		return 1
	fi

	# Get a list of all source variables.
	in_array source "${env_keys[@]}" && source_vars+=('source')
	mapfile -O "${#source_vars[@]}" -t source_vars < <(printf '%s\n' "${env_keys[@]}" | grep -E '.+_source$' | head -c -1)

	for arch_name in "${arch[@]}"; do
		mapfile -O "${#source_vars[@]}" -t source_vars < <(printf '%s\n' "${env_keys[@]}" | grep "^source_${arch_name}\$" | head -c -1)
		mapfile -O "${#source_vars[@]}" -t source_vars < <(printf '%s\n' "${env_keys[@]}" | grep -E ".+_source_${arch_name}\$" | head -c -1)
	done

	# Get a list of hash variables that are used in the PKGBUILD.
	for hashtype in "${known_hash_algos[@]}"; do
		if in_array "${hashtype}sums" "${env_keys[@]}"; then
			hash_variables+=("${hashtype}sums")
		fi
		
		mapfile -O "${#hash_variables[@]}" -t hash_variables < <(printf '%s\n' "${env_keys[@]}" | grep -E ".+_${hashtype}sums$" | head -c -1)

		for arch_name in "${arch[@]}"; do
			in_array "${hashtype}sums_${arch_name}" "${env_keys[@]}" && hash_variables+=("${hashtype}sums_${arch_name}")
			mapfile -O "${#hash_variables[@]}" -t hash_variables < <(printf '%s\n' "${env_keys[@]}" | grep -E ".+_${hashtype}sums_${arch_name}\$" | head -c -1)
		done
	done
	
	# If we have sources but not hashes, that's an error.
	if [[ "${#source_vars[@]}" != 0 && "${#hash_variables[@]}" == 0 ]]; then
		error "$(gettext "Sources were listed but no hashes could be found.")"
		return 1
	fi

	# Check that each source item has a matching hash item for each hash type used in the PKGBUILD, and that the hash array length is equal to the source length.
	for src in "${source_vars[@]}"; do
		distro="$(echo "${src}" | sed 's|source.*||' | sed 's|_$||')"
		arch_name="$(echo "${src}" | sed 's|.*source||' | sed 's|^_||')"

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
			
			if ! in_array "${hash_var}" "${env_keys[@]}"; then
				continue
			fi

			hash_values="${hash_var}[@]"
			hash_values=("${!hash_values}")

			source_values="${src}[@]"
			source_values=("${!source_values}")

			if [[ "${#source_values[@]}" -gt "${#hash_values[@]}" ]]; then
				error "$(gettext "Couldn't find enough hashsums for '%s' under '%s'.")" "${src}" "${hash_var}"
				ret=1
			elif [[ "${#source_values[@]}" -lt "${#hash_values[@]}" ]]; then
				error "$(gettext "Found too many hashsums for '%s' under '%s'.")" "${src}" "${hash_var}"
				ret=1
			fi
			
			remove_from_array "${hash_var}" hash_variables
		done
	done

	# If there's any hash variables we didn't remove, it's because we couldn't find a corresponding source entry for it.
	if [[ "${#hash_variables[@]}" != 0 ]]; then
		for hash_var in "${hash_variables[@]}"; do
			# Separate the parts of the hash algorithm into the hashtype, distro, and architecture.
			for hashtype in "${known_hash_algos[@]}"; do
				if echo "${hash_var}" | grep -q "${hashtype}sums"; then
					break
				fi
			done

			distro="$(echo "${hash_var}" | sed "s|${hashtype}sums.*||" | sed 's|_$||')"
			arch_name="$(echo "${hash_var}" | sed "s|.*${hashtype}sums||" | sed 's|^_||')"

			# Print the error, with the recommended source to add.
			if [[ -n "${distro}" && -n "${arch_name}" ]]; then
				error "$(gettext "Found unused hash variable '%s'. Maybe add '%s'?")" "${hash_var}" "${distro}_source_${arch_name}"
			elif [[ -n "${distro}" ]]; then
				error "$(gettext "Found unused hash variable '%s'. Maybe add '%s'?")" "${hash_var}" "${distro}_source"
			elif [[ -n "${arch_name}" ]]; then
				error "$(gettext "Found unused hash variable '%s'. Maybe add '%s'?")" "${hash_var}" "source_${arch}"
			else
				error "$(gettext "Found unused hash variable '%s'. Maybe add '%s'?")" "${hash_var}" "source"
			fi
		done

		ret=1
	fi

	return "${ret}"
}
