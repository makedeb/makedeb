#!/bin/bash
#
#   verify_checksum.sh - functions for checking source checksums
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

[[ -n "$LIBMAKEPKG_INTEGRITY_VERIFY_CHECKSUM_SH" ]] && return
LIBMAKEPKG_INTEGRITY_CHECKSUM_SH=1

LIBRARY=${LIBRARY:-'/usr/share/makepkg'}

source "$LIBRARY/util/message.sh"
source "$LIBRARY/util/pkgbuild.sh"
source "$LIBRARY/util/schema.sh"

check_checksums() {
	(( SKIPCHECKSUMS )) && return 0
	local distro
	local arch_name

	if in_array "${MAKEDEB_DISTRO_CODENAME}_source_${MAKEDEB_DPKG_ARCHITECTURE}" "${env_keys[@]}"; then
		distro="${MAKEDEB_DISTRO_CODENAME}_"
		arch_name="_${MAKEDEB_DPKG_ARCH}"
	elif in_array "${MAKEDEB_DISTRO_CODENAME}_source" "${env_keys[@]}"; then
		distro="${MAKEDEB_DISTRO_CODENAME}_"
		arch_name=""
	elif in_array "source_${MAKEDEB_DPKG_ARCHITECTURE}" "${env_keys[@]}"; then
		distro=""
		arch_name="_${MAKEDEB_DPKG_ARCHITECTURE}"
	else
		distro=""
		arch_name=""
	fi

	for integ in "${known_hash_algos[@]}"; do
		if in_array "${distro}${integ}sums${arch_name}" "${env_keys[@]}"; then
			verify_integrity_sums "${distro}source${arch_name}" "${distro}${integ}sums${arch_name}" "${integ}"
		fi
	done
}

verify_integrity_one() {
	local source_name=$1 integ=$2 expectedsum=$3

	local file="$(get_filename "$source_name")"
	printf '    %s ... ' "$file" >&2

	if [[ $expectedsum = 'SKIP' ]]; then
		printf '%s\n' "$(gettext "Skipped")" >&2
		return
	fi

	if ! file="$(get_filepath "$file")"; then
		printf '%s\n' "$(gettext "NOT FOUND")" >&2
		return 1
	fi

	local realsum="$("${integ}sum" "$file")"
	realsum="${realsum%% *}"
	if [[ ${expectedsum,,} = "$realsum" ]]; then
		printf '%s\n' "$(gettext "Passed")" >&2
	else
		printf '%s\n' "$(gettext "FAILED")" >&2
		return 1
	fi

	return 0
}

verify_integrity_sums() {
	local srcname="${1}" integvar="${2}" integ="${3}" integrity_sums=() sources=() srcname

	array_build integrity_sums "${integvar}"

	array_build sources "$srcname"
	if (( ${#integrity_sums[@]} == 0 && ${#sources[@]} == 0 )); then
		return 1
	fi

	msg "$(gettext "Validating %s files with %s...")" "${srcname}" "${integvar}"
	local idx errors=0
	for (( idx = 0; idx < ${#sources[*]}; idx++ )); do
		verify_integrity_one "${sources[idx]}" "${integ}" "${integrity_sums[idx]}" || errors=1
	done

	if (( errors )); then
		error "$(gettext "One or more files did not pass the validity check!")"
		exit 1 # TODO: error code
	fi
}
