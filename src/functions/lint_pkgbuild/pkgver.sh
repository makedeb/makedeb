#!/bin/bash
#
#   pkgver.sh - Check the 'pkgver' variable conforms to requirements.
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

[[ -n "$LIBMAKEPKG_LINT_PKGBUILD_PKGVER_SH" ]] && return
LIBMAKEPKG_LINT_PKGBUILD_PKGVER_SH=1

source "${LIBRARY:-'/usr/share/makepkg'}/util/message.sh"


lint_pkgbuild_functions+=('lint_pkgver')


check_pkgver() {
	local ret=0
	local ver=$1
	local type=$2

	if [[ -z $ver ]]; then
		error "$(gettext "%s is not allowed to be empty.")" "pkgver${type:+ in $type}"
		return 1
	fi

#    invalid_characters="$(echo "${ver}" | sed 's|[a-z0-9.+~]||g')"

#    if [[ "${invalid_characters:+x}" == "x" ]]; then
#	    error "$(gettext "%s contains invalid characters.")" "pkgver${type:+ in $type}"
#	    ret=1
#    fi

    if ! echo "${pkgver:0:1}" | grep -q '[0-9]'; then
	    error "$(gettext "%s doesn't start with a digit.")" "pkgver${type:+ in $type}"
	    ret=1
    fi

    return "${ret}"
}

lint_pkgver() {
	check_pkgver "$pkgver"
}
