#!/bin/bash
#
#   buildenv.sh - functions for altering the build environment before
#   compilation
#
#   Copyright (c) 2015-2021 Pacman Development Team <pacman-dev@archlinux.org>
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

[[ -n "$LIBMAKEPKG_BUILDENV_SH" ]] && return
LIBMAKEPKG_BUILDENV_SH=1

declare -a buildenv_functions build_options

for lib in "${LIBRARY:-/usr/share/makepkg}/buildenv/"*.sh; do
	source "$lib"
done

readonly -a buildenv_functions build_options

prepare_buildenv() {
	for func in ${buildenv_functions[@]}; do
		$func
	done

	# Ensure all necessary build variables are exported.
	export CPPFLAGS CFLAGS CXXFLAGS LDFLAGS RUSTFLAGS MAKEFLAGS CHOST

	# Load extensions.
	load_extensions
}
