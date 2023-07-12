#!/bin/bash
#
#   source.sh - functions for downloading and extracting sources
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

[[ -n "$LIBMAKEPKG_SOURCE_SH" ]] && return
LIBMAKEPKG_SOURCE_SH=1

for i in pkgbuild message source; do
    source "${LIBRARY:-'/usr/share/makepkg'}/util/${i}.sh"
done



for lib in "$LIBRARY/source/"*.sh; do
	source "$lib"
done


download_sources() {
	local netfile all_sources
	local get_source_fn=get_all_sources_for_arch get_vcs=1

	msg "$(gettext "Retrieving sources...")"

	while true; do
		case $1 in
			allarch)
				get_source_fn=get_all_sources
				;;
			novcs)
				get_vcs=0
				;;
			*)
				break
				;;
		esac
		shift
	done

	"$get_source_fn" 'all_sources'
	for netfile in "${all_sources[@]}"; do
		pushd "$SRCDEST" &>/dev/null

		local proto=$(get_protocol "$netfile")
		if declare -f download_$proto > /dev/null; then
			download_$proto "$netfile"
		else
			download_file "$netfile"
		fi

		popd &>/dev/null
	done
}

#get_all_local_sources_for_arch() {
#    local netfile all_sources
#    local local_sources=()
    
#	get_all_sources_for_arch 'all_sources'
#	for netfile in "${all_sources[@]}"; do
#		local proto=$(get_protocol "$netfile")
#		if declare -f extract_$proto > /dev/null; then
	#		extract_$proto "$netfile"
#		else
#			local_sources+=("$netfile")
#		fi
#	done
#}

extract_sources() {
	local netfile all_sources
    
	get_all_sources_for_arch 'all_sources'
	for netfile in "${all_sources[@]}"; do
		local proto=$(get_protocol "$netfile")
		if declare -f extract_$proto > /dev/null; then
			extract_$proto "$netfile"
		else
			extract_file "$netfile"
		fi
	done
}
