#!/bin/bash
#
#   pkglist.sh - Check the packages selected to build exist.
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

[[ -n "$LIBMAKEPKG_LINT_PKGBUILD_PKGLIST_SH" ]] && return
LIBMAKEPKG_LINT_PKGBUILD_PKGLIST_SH=1


for i in message util; do
    source "${LIBRARY:-'/usr/share/makepkg'}/util/${i}.sh"
done
#source "$LIBRARY/util/util.sh"


lint_pkgbuild_functions+=('lint_pkglist')


lint_pkglist() {
	local i ret=0

	for i in "${PKGLIST[@]}"; do
		if ! in_array "$i" "${pkgname[@]}"; then
			error "$(gettext "Requested package %s is not provided in %s")" "$i" "$BUILDFILE"
			ret=1
		fi
	done

	return $ret
}
