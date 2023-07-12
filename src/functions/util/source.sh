#!/bin/bash
#
#   source.sh - functions to extract information from source URLs
#
#   Copyright (c) 2010-2021 Pacman Development Team <pacman-dev@archlinux.org>
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

[[ -n "$LIBMAKEPKG_UTIL_SOURCE_SH" ]] && return
LIBMAKEPKG_UTIL_SOURCE_SH=1

source "${LIBRARY:-'/usr/share/makepkg'}/util/message.sh"


# a source entry can have two forms :
# 1) "filename::http://path/to/file"
# 2) "http://path/to/file"

# extract the URL from a source entry
get_url() {
	# strip an eventual filename
	printf "%s\n" "${1#*::}"
}

# extract the protocol from a source entry - return "local" for local sources
get_protocol() {
	if [[ $1 = *://* ]]; then
		# strip leading filename
		local proto="${1#*::}"
		proto="${proto%%://*}"
		# strip proto+uri://
		printf "%s\n" "${proto%%+*}"
	elif [[ $1 = *lp:* ]]; then
		local proto="${1#*::}"
		printf "%s\n" "${proto%%+lp:*}"
	else
		printf "%s\n" local
	fi
}

# extract the filename from a source entry
get_filename() {
	local netfile=$1

	# if a filename is specified, use it
	if [[ $netfile = *::* ]]; then
		printf "%s\n" "${netfile%%::*}"
		return
	fi

	local proto=$(get_protocol "$netfile")

	case $proto in
		git|svn)
			filename=${netfile%%#*}
			filename=${filename%%\?*}
			filename=${filename%/}
			filename=${filename##*/}
			if [[ $proto = git ]]; then
				filename=${filename%%.git*}
			fi
			;;
		*)
			# if it is just an URL, we only keep the last component
			filename="${netfile##*/}"
			;;
	esac
	printf "%s\n" "${filename}"
}

# Return the absolute filename of a source entry
get_filepath() {
	local file="$(get_filename "$1")"
	local proto="$(get_protocol "$1")"

	case $proto in
		git|svn)
			if [[ -d "$startdir/$file" ]]; then
				file="$startdir/$file"
			elif [[ -d "$SRCDEST/$file" ]]; then
				file="$SRCDEST/$file"
			else
				return 1
			fi
			;;
		*)
			if [[ -f "$startdir/$file" ]]; then
				file="$startdir/$file"
			elif [[ -f "$SRCDEST/$file" ]]; then
				file="$SRCDEST/$file"
			else
				return 1
			fi
			;;
	esac

	printf "%s\n" "$file"
}

# extract the VCS revision/branch specifier from a source entry
get_uri_fragment() {
	local netfile=$1

	local fragment=${netfile#*#}
	if [[ $fragment = "$netfile" ]]; then
		unset fragment
	fi
	fragment=${fragment%\?*}

	printf "%s\n" "$fragment"
}

# extract the VCS "signed" status from a source entry
get_uri_query() {
	local netfile=$1

	local query=${netfile#*\?}
	if [[ $query = "$netfile" ]]; then
		unset query
	fi
	query=${query%#*}

	printf "%s\n" "$query"
}

get_downloadclient() {
	local proto=$1

	# loop through DOWNLOAD_AGENTS variable looking for protocol
	local i
	for i in "${DLAGENTS[@]}"; do
		local handler="${i%%::*}"
		if [[ $proto = "$handler" ]]; then
			local agent="${i#*::}"
			break
		fi
	done

	# if we didn't find an agent, return an error
	if [[ -z $agent ]]; then
		error "$(gettext "Unknown download protocol: %s")" "$proto"
		plainerr "$(gettext "Aborting...")"
		exit 1 # $E_CONFIG_ERROR
	fi

	# ensure specified program is installed
	local program="${agent%% *}"
	if [[ ! -x $program ]]; then
		local baseprog="${program##*/}"
		error "$(gettext "The download program %s is not installed.")" "$baseprog"
		plainerr "$(gettext "Aborting...")"
		exit 1 # $E_MISSING_PROGRAM
	fi

	printf "%s\n" "$agent"
}
