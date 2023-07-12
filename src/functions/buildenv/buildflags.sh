#!/bin/bash
#
#   buildflags.sh - Clear user-specified buildflags if requested
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

[[ -n "$LIBMAKEPKG_BUILDENV_BUILDFLAGS_SH" ]] && return
LIBMAKEPKG_BUILDENV_BUILDFLAGS_SH=1

source "${LIBRARY:-/usr/share/makepkg}/util/option.sh"

build_options+=('buildflags')
buildenv_functions+=('buildenv_buildflags')

buildenv_buildflags() {
	if check_option "buildflags" "n"; then
		unset CPPFLAGS CFLAGS DEBUG_CFLAGS CXXFLAGS DEBUG_CXXFLAGS LDFLAGS RUSTFLAGS DEBUG_RUSTFLAGS
	fi
}
