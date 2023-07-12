#!/bin/bash
#
#   sudo.sh - Confirm presence of sudo binary
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

[[ -n "$LIBMAKEPKG_EXECUTABLE_SUDO_SH" ]] && return
LIBMAKEPKG_EXECUTABLE_SUDO_SH=1

source "${LIBRARY:-'/usr/share/makepkg'}/util/message.sh"

executable_functions+=('executable_sudo')

executable_sudo() {
    if (( DEP_BIN || RMDEPS || INSTALL || SYNCDEPS)); then
        if (( ${#PACMAN_AUTH[@]} == 0 )); then
            if ! type -p sudo >/dev/null; then
                warning "$(gettext "Cannot find the %s binary. Will use %s to acquire root privileges.")" "sudo" "su"
                sudo() {
                    su root -c "$(printf '%q ' "${@}")"
                }
            fi
        else 
            if in_array '%c' "${PACMAN_AUTH[@]}"; then
				sudo (){
                    "${PACMAN_AUTH[@]/\%c/$(printf '%q ' "${@}")}"
                }
			else
				sudo (){
                    "${PACMAN_AUTH[@]}" "${@}"
                }
			fi
        fi
    fi
}
