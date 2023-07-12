#!/bin/bash
#
#   compress.sh - functions to compress archives in a uniform manner
#
#   Copyright (c) 2017-2021 Pacman Development Team <pacman-dev@archlinux.org>
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

[[ -n "$LIBMAKEPKG_UTIL_COMPRESS_SH" ]] && return
LIBMAKEPKG_UTIL_COMPRESS_SH=1


for i in pkgbuild message; do
    source "${LIBRARY:-'/usr/share/makepkg'}/util/${i}.sh"
done

# Wrapper around many stream compression formats, for use in the middle of a
# pipeline. A tar archive is passed on stdin and compressed to stdout.
compress_as() {
	# $1: final archive filename extension for compression type detection

	local cmd ext=${1#${1%.tar*}}

	if ! get_compression_command "$ext" cmd; then
		warning "$(gettext "'%s' is not a valid archive extension.")" "${ext:-${1##*/}}"
		cat
	else
		"${cmd[@]}"
	fi
}

# Retrieve the compression command for an archive extension, or cat for .tar,
# and save it to an existing array name. If the extension cannot be found,
# clear the array and return failure.
get_compression_command() {
	local extarray ext=$1 outputvar=$2
	local resolvecmd=() fallback=()

	case "$ext" in
		*.tar.gz)  fallback=(gzip -c -f -n) ;;
		*.tar.bz2) fallback=(bzip2 -c -f) ;;
		*.tar.xz)  fallback=(xz -c -z -) ;;
		*.tar.zst) fallback=(zstd -c -z -q -) ;;
		*.tar.lrz) fallback=(lrzip -q) ;;
		*.tar.lzo) fallback=(lzop -q) ;;
		*.tar.Z)   fallback=(compress -c -f) ;;
		*.tar.lz4) fallback=(lz4 -q) ;;
		*.tar.lz)  fallback=(lzip -c -f) ;;
		*.tar)     fallback=(cat) ;;
		# do not respect unknown COMPRESS* env vars
		*)        array_build "$outputvar" resolvecmd; return 1 ;;
	esac

	ext=${ext#*.tar.}
	# empty the variable for plain tar archives so we fallback to cat
	ext=${ext#*.tar}

	if [[ -n $ext ]]; then
		extarray="COMPRESS${ext^^}[@]"
		resolvecmd=("${!extarray}")
	fi
	if (( ${#resolvecmd[@]} == 0 )); then
		resolvecmd=("${fallback[@]}")
	fi

	array_build "$outputvar" resolvecmd
}
