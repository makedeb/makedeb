#!/bin/bash
#
#   util.sh - general utility functions
#
#   Copyright (c) 2006-2021 Pacman Development Team <pacman-dev@archlinux.org>
#   Copyright (c) 2002-2006 by Judd Vinet <jvinet@zeroflux.org>
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

[[ -n "$LIBMAKEPKG_UTIL_UTIL_SH" ]] && return
LIBMAKEPKG_UTIL_UTIL_SH=1

LIBRARY=${LIBRARY:-'/usr/share/makepkg'}

source "$LIBRARY/util/error.sh"
source "$LIBRARY/util/message.sh"

##
#  usage : in_array( $needle, $haystack )
# return : 0 - found
#          1 - not found
##
in_array() {
	local needle=$1; shift
	local item
	for item in "$@"; do
		[[ $item = "$needle" ]] && return 0 # Found
	done
	return 1 # Not Found
}

# tests if a variable is an array
is_array() {
	local v=$1
	local ret=1

	if [[ ${!v@a} = *a* ]]; then
		ret=0
	fi

	return $ret
}

# Remove an item from an array.
remove_from_array() {
	local match="${1}"
	declare -n "ref=${2}"
	mapfile -t array_items < <(seq 0 $(( "${#ref[@]}" - 1 )) | sort -r)

	for index in "${array_items[@]}"; do
		if [[ "${ref[$index]}" == "${match}" ]]; then
			unset "ref[$index]"
		fi
	done

	# Bash indexes don't automatically go down when we remove an item from them, so we need to reset it ourself.
	ref=("${ref[@]}")

	unset -n ref
}

# Finds how many occurances of a string are in an array.
occurances_in_array() {
	local item="${1}"
	local values="${@:2}"
	local -i matches=0

	for value in "${values[@]}"; do
		if [[ "${item}" == "${value}" ]]; then
			matches+=1
		fi
	done

	echo "${matches}"
	return 0
}

# Canonicalize a directory path if it exists
canonicalize_path() {
	local path="$1"

	if [[ -d $path ]]; then
		(
			cd_safe "$path"
			pwd -P
		)
	else
		printf "%s\n" "$path"
	fi
}

dir_is_empty() {
	(
		shopt -s dotglob nullglob
		files=("$1"/*)
		(( ${#files} == 0 ))
	)
}

cd_safe() {
    if ! (( PRINTCONTROL )) && ! cd "$1"; then
		error "$(gettext "Failed to change to directory %s")" "$1"
		plainerr "$(gettext "Aborting...")"
		exit 1
	fi
}

# Try to create directory if one does not yet exist. Fails if the directory
# exists but has no write permissions, or if there is an existing file with
# the same name.
ensure_writable_dir() {
	local dirtype="$1" dirpath="$2"

	if ! mkdir -p "$dirpath" 2>/dev/null; then
		error "$(gettext "Failed to create the directory \$%s (%s).")" "$dirtype" "$dirpath"
		return 1
	elif [[ ! -w $dirpath ]]; then
		error "$(gettext "You do not have write permission for the directory \$%s (%s).")" "$dirtype" "$dirpath"
		return 1
	fi

	return 0
}

# source a file and fail if it does not succeed
source_safe() {
	local shellopts=$(shopt -p extglob)
	shopt -u extglob

	if ! source "$@"; then
		error "$(gettext "Failed to source %s")" "$1"
		exit $E_MISSING_FILE
	fi

	eval "$shellopts"
}

create_array() {
  local target_variable="${1}" \
        array_data=("${@:2}")

  local -n var_ref="${target_variable}"

  var_ref=("${array_data[@]}")

  declare -g "${target_variable}"
  unset -n var_ref
}

# Read environment variables and functions.
read_env() {
	mapfile -t env_vars < <(set | grep '^[^= ]*=' | grep '^[^_]')
	mapfile -t env_keys < <(printf '%s\n' "${env_vars[@]}" | grep -o '^[^=]*' | grep '^[^_]')
	mapfile -t env_funcs < <(set | grep '^[a-zA-Z_-]* () $' | sed 's| () ||')
}
