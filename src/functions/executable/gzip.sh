#!/bin/bash
#
#   gzip.sh - Confirm presence of gzip binary
#
#   Copyright (c) 2011-2021 Pacman Development Team <pacman-dev@archlinux.org>
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

[[ -n "$LIBMAKEPKG_EXECUTABLE_GZIP_SH" ]] && return
LIBMAKEPKG_EXECUTABLE_GZIP_SH=1


for i in message option; do
    source "${LIBRARY:-'/usr/share/makepkg'}/util/${i}.sh"
done 


executable_functions+=('executable_gzip')

executable_gzip() {
	if check_option "zipman" "y"; then
		if ! type -p gzip >/dev/null; then
			error "$(gettext "Cannot find the %s binary required for compressing man and info pages.")" "gzip"
			return 1
		fi
	fi
}
