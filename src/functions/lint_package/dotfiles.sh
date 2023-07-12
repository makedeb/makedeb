#!/bin/bash
#
#   dotfiles.sh - check for dotfiles in the package root
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

[[ -n "$LIBMAKEPKG_LINT_PACKAGE_DOTFILES_SH" ]] && return
LIBMAKEPKG_LINT_PACKAGE_DOTFILES_SH=1

source "${LIBRARY:-'/usr/share/makepkg'}/util/message.sh"

lint_package_functions+=('check_dotfiles')

check_dotfiles() {
    local ret=0
    local dotfiles
    mapfile -t dotfiles < <(find -mindepth 1 -maxdepth 1 -name '.*' | sed 's|^\./||' | grep '^\.')
    for f in "${dotfiles[@]}"; do
        error "$(gettext "Dotfile found in package root '%s'")" "$f"
        ret=1
    done
    return $ret
}
