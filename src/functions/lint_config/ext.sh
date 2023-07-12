#!/bin/bash
#
#   ext.sh - Check that source/package extensions have valid prefixes
#
#   Copyright (c) 2019-2021 Pacman Development Team <pacman-dev@archlinux.org>
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

[[ -n "$LIBMAKEPKG_LINT_CONFIG_EXT_SH" ]] && return
LIBMAKEPKG_LINT_CONFIG_EXT_SH=1

source "$LIBRARY/util/message.sh"

lint_config_functions+=('lint_ext')


lint_ext() {
	local i var val ret=0

	for i in 'SRCEXT/.src.tar' 'PKGEXT/.pkg.tar';  do
		IFS='/' read -r var val < <(printf '%s\n' "$i")

		if [[ ${!var} != ${val}* ]]; then
			error "$(gettext "%s does not contain a valid package suffix (needs '%s', got '%s')")" \
				"\$${var}" "${val}*" "${!var}"
			ret=1
		fi
	done

	return $ret
}
