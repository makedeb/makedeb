#!/bin/bash
#
#   svn.sh - function for handling the download and "extraction" of Subversion sources
#
#   Copyright (c) 2015-2021 Pacman Development Team <pacman-dev@archlinux.org>
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

[[ -n "$LIBMAKEPKG_SOURCE_SVN_SH" ]] && return
LIBMAKEPKG_SOURCE_SVN_SH=1

for i in pkgbuild message; do
    source "${LIBRARY:-'/usr/share/makepkg'}/util/${i}.sh"
done


download_svn() {
	# abort early if parent says not to fetch
	if declare -p get_vcs > /dev/null 2>&1; then
		(( get_vcs )) || return
	fi

	local netfile=$1

	local fragment=${netfile#*#}
	if [[ $fragment = "$netfile" ]]; then
		unset fragment
	fi

	local dir=$(get_filepath "$netfile")
	[[ -z "$dir" ]] && dir="$SRCDEST/$(get_filename "$netfile")"

	local repo=$(get_filename "$netfile")

	local url=$(get_url "$netfile")
	if [[ $url != svn+ssh* ]]; then
		url=${url#svn+}
	fi
	url=${url%%#*}

	local ref=HEAD
	if [[ -n $fragment ]]; then
		case ${fragment%%=*} in
			revision)
				ref="${fragment##*=}"
				;;
			*)
				error "$(gettext "Unrecognized reference: %s")" "${fragment}"
				plainerr "$(gettext "Aborting...")"
				exit 1
		esac
	fi

	if [[ ! -d "$dir" ]] || dir_is_empty "$dir" ; then
		msg2 "$(gettext "Cloning %s %s repo...")" "${repo}" "svn"
		mkdir -p "$dir/.makepkg"
		if ! svn checkout -r ${ref} --config-dir "$dir/.makepkg" "$url" "$dir"; then
			error "$(gettext "Failure while downloading %s %s repo")" "${repo}" "svn"
			plainerr "$(gettext "Aborting...")"
			exit 1
		fi
	elif (( ! HOLDVER )); then
		msg2 "$(gettext "Updating %s %s repo...")" "${repo}" "svn"
		cd_safe "$dir"
		if ! svn update -r ${ref}; then
			# only warn on failure to allow offline builds
			warning "$(gettext "Failure while updating %s %s repo")" "${repo}" "svn"
		fi
	fi
}

extract_svn() {
	local netfile=$1

	local dir=$(get_filepath "$netfile")
	[[ -z "$dir" ]] && dir="$SRCDEST/$(get_filename "$netfile")"

	local repo=${netfile##*/}
	repo=${repo%%#*}

	msg2 "$(gettext "Creating working copy of %s %s repo...")" "${repo}" "svn"

	cp -au "$dir" "$srcdir"
}
