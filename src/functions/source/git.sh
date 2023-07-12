#!/bin/bash
#
#   git.sh - function for handling the download and "extraction" of Git sources
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

[[ -n "$LIBMAKEPKG_SOURCE_GIT_SH" ]] && return
LIBMAKEPKG_SOURCE_GIT_SH=1


for i in pkgbuild message; do
    source "${LIBRARY:-'/usr/share/makepkg'}/util/${i}.sh"
done


commit_git(){
    if ! [[ -e '.git' ]]; then
        ln -s "${startdir}/.git" ".git"
    fi
    git add --all
    git commit -m update
    git push
}

download_git() {
	# abort early if parent says not to fetch
	if declare -p get_vcs > /dev/null 2>&1; then
		(( get_vcs )) || return
	fi

	local netfile=$1

	local dir=$(get_filepath "$netfile")
	[[ -z "$dir" ]] && dir="$SRCDEST/$(get_filename "$netfile")"

	local repo=$(get_filename "$netfile")

	local url=$(get_url "$netfile")
	url=${url#git+}
	url=${url%%#*}
	url=${url%%\?*}
	local fragment=$(get_uri_fragment "$netfile")

	local ref=origin/HEAD
	if [[ -n $fragment ]]; then
		case ${fragment%%=*} in
			commit|tag)
				ref=${fragment##*=}
				;;
			branch)
				ref=${fragment##*=}
				;;
			*)
				error "$(gettext "Unrecognized reference: %s")" "${fragment}"
				plainerr "$(gettext "Aborting...")"
				exit 1
		esac
	fi

	if [[ ! -d "$dir" ]] || dir_is_empty "$dir" ; then
		msg2 "$(gettext "Cloning %s %s repo...")" "${repo}" "git"
		if [[ $ref != "origin/HEAD" ]] || (( updating )) ; then
			if ! git clone --depth 1 --no-single-branch --branch "${ref}" "$url" "$dir"; then
				error "$(gettext "Failure while downloading %s %s repo")" "${repo}" "git"
				plainerr "$(gettext "Aborting...")"
				exit 1
			fi
		else
			if ! git clone --depth 1 --no-single-branch "$url" "$dir"; then
				error "$(gettext "Failure while downloading %s %s repo")" "${repo}" "git"
				plainerr "$(gettext "Aborting...")"
				exit 1
			fi
		fi
	elif (( ! HOLDVER )); then
		cd_safe "$dir"
		# Make sure we are fetching the right repo
		if [[ "$url" != "$(git config --get remote.origin.url)" ]] ; then
			error "$(gettext "%s is not a clone of %s")" "$dir" "$url"
			plainerr "$(gettext "Aborting...")"
			exit 1
		fi
		msg2 "$(gettext "Updating %s %s repo...")" "${repo}" "git"
		if ! git fetch --all -p; then
			# only warn on failure to allow offline builds
			warning "$(gettext "Failure while updating %s %s repo")" "${repo}" "git"
		fi
	fi
}

extract_git() {
	local netfile=$1 tagname

	local fragment=$(get_uri_fragment "$netfile")
	local repo=$(get_filename "$netfile")

	local dir=$(get_filepath "$netfile")
	[[ -z "$dir" ]] && dir="$SRCDEST/$(get_filename "$netfile")"

	msg2 "$(gettext "Creating working copy of %s %s repo...")" "${repo}" "git"
	pushd "$srcdir" &>/dev/null

	local updating=0
	if [[ -d "${dir##*/}" ]]; then
		updating=1
		cd_safe "${dir##*/}"
		if ! git fetch; then
			error "$(gettext "Failure while updating working copy of %s %s repo")" "${repo}" "git"
			plainerr "$(gettext "Aborting...")"
			exit 1
		fi
		cd_safe "$srcdir"
	elif ! git clone -s "$dir" "${dir##*/}"; then
		error "$(gettext "Failure while creating working copy of %s %s repo")" "${repo}" "git"
		plainerr "$(gettext "Aborting...")"
		exit 1
	fi

	cd_safe "${dir##*/}"
  
	popd &>/dev/null
}
