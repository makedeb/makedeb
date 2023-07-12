#!/bin/bash
#
#   file_names.sh - check package file names
#
#   Copyright (c) 2016-2021 Pacman Development Team <pacman-dev@archlinux.org>
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

[[ -n "$LIBMAKEPKG_LINT_PACKAGE_FILE_NAMES_SH" ]] && return
LIBMAKEPKG_LINT_PACKAGE_FILE_NAMES_SH=1

source "${LIBRARY:-'/usr/share/makepkg'}/util/message.sh"

lint_package_functions+=('lint_file_names')

lint_file_names() {
	local ret=0 paths

	# alpm's local database format does not support newlines in paths
	mapfile -t paths < <(find "$pkgdir" -name \*$'\n'\*)
	if  (( ${#paths} > 0 )); then
		error "$(gettext 'Package contains paths with newlines')"
		printf '%s\n' "${paths[@]}" >&2
		ret=1
	fi

	return $ret
}
