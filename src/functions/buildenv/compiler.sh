#!/bin/bash
#
#   compiler.sh - CCache and DistCC compilation
#   ccache - Cache compilations and reuse them to save time on repetitions
#   distcc - Distribute compilation of C and C++ across machines
#
#   Copyright (c) 2007-2021 Pacman Development Team <pacman-dev@archlinux.org>
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

[[ -n "$LIBMAKEPKG_BUILDENV_COMPILER_SH" ]] && return
LIBMAKEPKG_BUILDENV_COMPILER_SH=1

source "${LIBRARY:-/usr/share/makepkg}/util/option.sh"

build_options+=('ccache' 'distcc')
buildenv_functions+=('buildenv_ccache' 'buildenv_distcc')

using_ccache=0

buildenv_ccache() {
	if check_buildoption "ccache" "y"; then
		if [ -d /usr/lib/ccache/bin ]; then
			export PATH="/usr/lib/ccache/bin:$PATH"
			using_ccache=1
		fi
	fi
}

buildenv_distcc() {
	if check_buildoption "distcc" "y"; then
		if (( using_ccache )); then
			if [[ " $CCACHE_PREFIX " != *" distcc "* ]]; then
				export CCACHE_PREFIX="${CCACHE_PREFIX:+$CCACHE_PREFIX }distcc"
			fi
			export CCACHE_BASEDIR="$srcdir"
		elif [[ -d /usr/lib/distcc/bin ]]; then
			export PATH="/usr/lib/distcc/bin:$PATH"
		fi

		export DISTCC_HOSTS
	fi
}
