#!/bin/bash
#
#   util.sh - utility functions for pkgbuild linting.
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

[[ -n "$LIBMAKEPKG_LINT_PKGBUILD_UTIL_SH" ]] && return
LIBMAKEPKG_LINT_PKGBUILD_UTIL_SH=1

source "${LIBRARY:-'/usr/share/makepkg'}/util/message.sh"


check_files_exist() {
	local kind=$1 files=("${@:2}") file ret=0

	for file in "${files[@]}"; do
		if [[ $file && ! -f $file ]]; then
			error "$(gettext "%s file (%s) does not exist or is not a regular file.")" \
				"$kind" "$file"
			ret=1
		fi
	done

	return $ret
}
