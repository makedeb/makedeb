#!/bin/bash
#
#   pkgbuild.sh - functions to extract information from PKGBUILD files
#
#   Copyright (c) 2009-2021 Pacman Development Team <pacman-dev@archlinux.org>
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

[[ -n "$LIBMAKEPKG_UTIL_PKGBUILD_SH" ]] && return
LIBMAKEPKG_UTIL_PKGBUILD_SH=1

source "$LIBRARY/util/schema.sh"


have_function() {
	declare -f "$1" >/dev/null
}

grep_function() {
	{ declare -f "$1" || declare -f package; } 2>/dev/null | grep -E "$2"
}

array_build() {
	local dest=$1 src=$2 i keys values

	# it's an error to try to copy a value which doesn't exist.
	declare -p "$2" &>/dev/null || return 1

	# Build an array of the indices of the source array.
	eval "keys=(\"\${!$2[@]}\")"

	# Clear the destination array
	eval "$dest=()"

	# Read values indirectly via their index. This approach gives us support
	# for associative arrays, sparse arrays, and empty strings as elements.
	for i in "${keys[@]}"; do
		values+=("printf -v '$dest[$i]' %s \"\${$src[$i]}\";")
	done

	eval "${values[*]}"
}

extract_global_variable() {
	# $1: variable name
	# $2: multivalued
	# $3: name of output var

	local attr=$1 isarray=$2 outputvar=$3 ref

	if (( isarray )); then
		array_build ref "$attr"
		(( ${#ref[@]} )) && array_build "$outputvar" "$attr"
	else
		[[ ${!attr} ]] && printf -v "$outputvar" %s "${!attr}"
	fi
}

extract_function_variable() {
	# $1: function name
	# $2: variable name
	# $3: multivalued
	# $4: name of output var

	local funcname=$1 attr=$2 isarray=$3 outputvar=$4 attr_regex= decl= r=1

	if (( isarray )); then
		printf -v attr_regex '^[[:space:]]* %s\+?=\(' "$2"
	else
		printf -v attr_regex '^[[:space:]]* %s\+?=[^(]' "$2"
	fi

	# this function requires extglob - save current status to restore later
	local shellopts=$(shopt -p extglob)
	shopt -s extglob

	while read -r; do
		# strip leading whitespace and any usage of declare
		decl=${REPLY##*([[:space:]])}
		eval "${decl/#$attr/$outputvar}"

		# entering this loop at all means we found a match, so notify the caller.
		r=0
	done < <(grep_function "$funcname" "$attr_regex")

	eval "$shellopts"

	return $r
}

exists_function_variable() {
	# $1: function name
	# $2: variable name

	local funcname=$1 attr=$2 out
	extract_function_variable "$funcname" "$attr" 0 out ||
		extract_function_variable "$funcname" "$attr" 1 out
}

get_pkgbuild_attribute() {
	# $1: package name
	# $2: attribute name
	# $3: multivalued
	# $4: name of output var

	local pkgname=$1 attrname=$2 isarray=$3 outputvar=$4

	if (( isarray )); then
		eval "$outputvar=()"
	else
		printf -v "$outputvar" %s ''
	fi

	if [[ $pkgname ]]; then
		extract_global_variable "$attrname" "$isarray" "$outputvar"
		extract_function_variable "package_$pkgname" "$attrname" "$isarray" "$outputvar"
	else
		extract_global_variable "$attrname" "$isarray" "$outputvar"
	fi
}

get_pkgbuild_all_split_attributes() {
	local attrname=$1 outputvar=$2 all_list list

	if extract_global_variable "$attrname" 1 list; then
		all_list+=("${list[@]}")
	fi
	for a in "${arch[@]}"; do
		if extract_global_variable "${attrname}_$a" 1 list; then
			all_list+=("${list[@]}")
		fi
	done

	for name in "${pkgname[@]}"; do
		if extract_function_variable "package_$name" "$attrname" 1 list; then
			all_list+=("${list[@]}")
		fi

		for a in "${arch[@]}"; do
			if extract_function_variable "package_$name" "${attrname}_$a" 1 list; then
				all_list+=("${list[@]}")
			fi
		done
	done

	(( ${#all_list[@]} )) && array_build "$outputvar" all_list
}

##
#  usage : get_full_version()
# return : full version spec, including epoch (if necessary), pkgver, pkgrel
##
get_full_version() {
	if (( epoch > 0 )) && ! (( "${NOEPOCH}" )); then
		printf "%s\n" "$epoch:$pkgver-$pkgrel"
	else
		printf "%s\n" "$pkgver-$pkgrel"
	fi
}

##
#  usage : get_pkg_arch( [$pkgname] )
# return : architecture of the package
##

get_pkg_arch() {
	if [[ -z $1 ]]; then
		if [[ $arch = "all" ]]; then
			printf "%s\n" "all"
		else
			printf "%s\n" "${MAKEDEB_DPKG_ARCHITECTURE}"
		fi
	else
		local arch_override
		get_pkgbuild_attribute "$1" arch 1 arch_override
		(( ${#arch_override[@]} == 0 )) && arch_override=("${arch[@]}")
		if [[ $arch_override = "all" ]]; then
			printf "%s\n" "all"
		else
			printf "%s\n" "${MAKEDEB_DPKG_ARCHITECTURE}"
		fi
	fi
}

print_all_package_names() {
	local version=$(get_full_version)
	local architecture pkg opts a
	for pkg in ${pkgname[@]}; do
		architecture=$(get_pkg_arch $pkg)
		printf "%s/%s-%s-%s%s\n" "$PKGDEST" "$pkg" "$version" "$architecture" "$PKGEXT"
	done
	if check_option "debug" "y" && check_option "strip" "y"; then
		architecture=$(get_pkg_arch)
		printf "%s/%s-%s-%s-%s%s\n" "$PKGDEST" "$pkgbase" "debug" "$version" "$architecture" "$PKGEXT"
	fi
}

get_all_sources() {
	local aggregate l a d

	if array_build l 'source'; then
		aggregate+=("${l[@]}")
	fi

	for d in $(printf '%s\n' "${env_keys[@]}" | grep '.*_source$'); do
		if array_build l "${d}"; then
			aggregate+=("${l[@]}")
		fi
	done

	for a in "${arch[@]}"; do
		if array_build l "source_${a}"; then
			aggregate+=("${l[@]}")
		fi

		for i in $(printf '%s\n' "${env_keys[@]}" | grep ".*_source_${a}\$"); do
			if array_build l "${i}"; then
				aggregate+=("${l[@]}")
			fi
		done
	done

	array_build "${1}" "aggregate"
}

get_all_sources_for_arch() {
	local aggregate l
	array_build l 'source' && aggregate=("${l[@]}")
	array_build l "${MAKEDEB_DISTRO_CODENAME}_source" && aggregate=("${l[@]}")
	array_build l "source_${MAKEDEB_DPKG_ARCHITECTURE}" && aggregate=("${l[@]}")
	array_build l "${MAKEDEB_DISTRO_CODENAME}_source_${MAKEDEB_DPKG_ARCHITECTURE}" && aggregate=("${l[@]}")
	array_build "${1}" "aggregate"
}

get_integlist() {
	local integ
	local integlist=()

	for integ in "${known_hash_algos[@]}"; do
		# check for e.g. "sha256sums"
		local sumname="${integ}sums[@]"
		if [[ -n ${!sumname} ]]; then
			integlist+=("$integ")
			continue
		fi

		# check for e.g. "sha256sums_amd64".
		for a in "${arch[@]}"; do
			local sumname="${integ}sums_${a}[@]"
			if [[ -n ${!sumname} ]]; then
				integlist+=("$integ")
				break
			fi
		done

		# check for e.g. 'jammy_sha256sums'.
		for d in $(printf '%s\n' "${env_keys[@]}" | grep ".*_${integ}sums\$"); do
			integlist+=("${integ}")
		done

		# check for e.g. 'jammy_sha256sums_amd64'.
		for a in "${arch[@]}"; do
			for d in $(printf '%s\n' "${env_keys[@]}" | grep ".*_${integ}sums_${a}"); do
				integlist+=("${integ}")
			done
		done
	done

	if (( ${#integlist[@]} > 0 )); then
		printf "%s\n" "${integlist[@]}"
	else
		printf "%s\n" "${INTEGRITY_CHECK[@]}"
	fi
}

# Get all occurances of a variable plus it's extensions (i.e. for 'depends',
# 'depends' and 'jammy_depends').
get_extended_variables() {
	printf '%s\n' "${env_keys[@]}" | grep -F "_${1}" | head -c -1
	printf '%s\n' "${env_keys[@]}" | grep -F "${1}_" | head -c -1

	if in_array "${1}" "${env_keys[@]}"; then
		echo "${1}"
	fi
}

# Split a dependency by it's pipe character, i.e.
# 'hi|me' -> 'hi' and 'me' returned.
split_dep_by_pipe() {
	echo "${1}" | sed 's/|/\n/g' | head -c -1
}

# Split a version into it's parts of 'epoch', 'pkgver', and 'pkgrel'.
split_version() {
	local ver="${1}"
	local -n epoch="${2}"
	local -n pkgver="${3}"
	local -n pkgrel="${4}"

	epoch="$(echo "${ver}" | grep ':' | sed 's|:.*||')"
	pkgver="$(echo "${ver}" | sed 's|^[^:]*:||' | sed 's|-.*||')"
	pkgrel="$(echo "${ver}" | grep '-' | sed 's|^[^-]*-||')"
}

# Convert Debian styled dependencies ('pkg (>> 1)') into makedeb styled ones ('pkg>1').
# This doesn't validate that passed in arguments are syntactically correct, make sure
# this is called from somewhere where sources have already been validated.
debian_to_makedeb_deps() {
	local prefix="${1}"
	local packages=("${@:2}")

	for pkg in "${packages[@]}"; do
		echo "${prefix}$(echo "${pkg}" | sed -e 's|[ ()]||g' -e 's|<<|<|g' -e 's|>>|>|g')"
	done
}
