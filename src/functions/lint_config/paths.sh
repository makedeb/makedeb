#!/bin/bash
#
#   paths.sh - Check that pathname components do not contain odd characters
#
#   Copyright (c) 2018-2021 Pacman Development Team <pacman-dev@archlinux.org>
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

[[ -n "$LIBMAKEPKG_LINT_CONFIG_PATHS_SH" ]] && return
LIBMAKEPKG_LINT_CONFIG_PATHS_SH=1

source "${LIBRARY:-'/usr/share/makepkg'}/util/message.sh"
source "${LIBRARY:-'/usr/share/makepkg'}/util/pkgbuild.sh"

lint_config_functions+=('lint_paths')


lint_paths() {
	local pathvars=(BUILDDIR PKGDEST SRCDEST SRCPKGDEST LOGDEST PKGEXT SRCEXT)

	local i ret=0

	for i in ${pathvars[@]}; do
		if [[ ${!i} = *$'\n'* ]]; then
			error "$(gettext "%s contains invalid characters: '%s'")" \
					"$i" "${!i//[^$'\n']}"
			ret=1
		fi
	done

	return $ret
}
