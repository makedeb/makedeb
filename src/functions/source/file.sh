#!/bin/bash
#
#   file.sh - function for handling the download and extraction of source files
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

[[ -n "$LIBMAKEPKG_SOURCE_FILE_SH" ]] && return
LIBMAKEPKG_SOURCE_FILE_SH=1


for i in pkgbuild message; do
    source "${LIBRARY:-'/usr/share/makepkg'}/util/${i}.sh"
done


download_file() {
	local netfile=$1

	local filepath=$(get_filepath "$netfile")
	if [[ -n "$filepath" ]]; then
		msg2 "$(gettext "Found %s")" "${filepath##*/}"
		return
	fi

	local proto=$(get_protocol "$netfile")

	# find the client we should use for this URL
	local -a cmdline
	IFS=' ' read -a cmdline < <(get_downloadclient "$proto")
	wait $! || exit

	local filename=$(get_filename "$netfile")
	local url=$(get_url "$netfile")

	if [[ $proto = "scp" ]]; then
		# scp downloads should not pass the protocol in the url
		url="${url##*://}"
	fi

	msg2 "$(gettext "Downloading %s...")" "$filename"

	# temporary download file, default to last component of the URL
	local dlfile="${url##*/}"

	# replace %o by the temporary dlfile if it exists
	if [[ ${cmdline[*]} = *%o* ]]; then
		dlfile=$filename.part
		cmdline=("${cmdline[@]//%o/$dlfile}")
	fi
	# add the URL, either in place of %u or at the end
	if [[ ${cmdline[*]} = *%u* ]]; then
		cmdline=("${cmdline[@]//%u/$url}")
	else
		cmdline+=("$url")
	fi

	if ! command -- "${cmdline[@]}" >&2; then
		[[ ! -s $dlfile ]] && rm -f -- "$dlfile"
		error "$(gettext "Failure while downloading %s")" "$url"
		plainerr "$(gettext "Aborting...")"
		exit 1
	fi

	# rename the temporary download file to the final destination
	if [[ $dlfile != "$filename" ]]; then
		mv -f "$SRCDEST/$dlfile" "$SRCDEST/$filename"
	fi
}

extract_file() {
	local netfile=$1

	local file=$(get_filename "$netfile")
	local filepath=$(get_filepath "$file")
	rm -f "$srcdir/${file}"
	ln -s "$filepath" "$srcdir/"

	if in_array "$file" "${noextract[@]}"; then
		# skip source files in the noextract=() array
		# these are marked explicitly to NOT be extracted
		return 0
	fi

	# do not rely on extension for file type
	local file_type=$(file -S -bizL -- "$file")
	local ext=${file##*.}
	local cmd=''
	case "$file_type" in
		*application/x-tar*|*application/zip*|*application/x-zip*|*application/x-cpio*)
			cmd="bsdtar" ;;
		*application/x-gzip*|*application/gzip*)
			case "$ext" in
				gz|z|Z) cmd="gzip" ;;
				*) return;;
			esac ;;
		*application/x-bzip*)
			case "$ext" in
				bz2|bz) cmd="bzip2" ;;
				*) return;;
			esac ;;
		*application/x-xz*)
			case "$ext" in
				xz) cmd="xz" ;;
				*) return;;
			esac ;;
		*application/zstd*)
			case "$ext" in
				zst) cmd="zstd" ;;
				*) return;;
			esac ;;
		*)
			# See if bsdtar can recognize the file
			if bsdtar -tf "$file" -q '*' &>/dev/null; then
				cmd="bsdtar"
			else
				return 0
			fi ;;
	esac

	local ret=0
	msg2 "$(gettext "Extracting %s with %s")" "$file" "$cmd"
	if [[ $cmd = "bsdtar" ]]; then
		$cmd -xf "$file" || ret=$?
	else
		rm -f -- "${file%.*}"
		$cmd -dcf -- "$file" > "${file%.*}" || ret=$?
	fi
	if (( ret )); then
		error "$(gettext "Failed to extract %s")" "$file"
		plainerr "$(gettext "Aborting...")"
		exit 1
	fi

	if (( EUID == 0 )); then
		# change perms of all source files to root user & root group
		chown -R 0:0 "$srcdir"
	fi
}
