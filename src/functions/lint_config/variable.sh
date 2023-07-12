#!/bin/bash
#
#   variable.sh - Check that variables are or are not arrays as appropriate
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

[[ -n "$LIBMAKEPKG_LINT_CONFIG_VARIABLE_SH" ]] && return
LIBMAKEPKG_LINT_CONFIG_VARIABLE_SH=1

source "${LIBRARY:-'/usr/share/makepkg'}/util/message.sh"

lint_config_functions+=('lint_config_variables')


lint_config_variables() {
	local array=(DLAGENTS VCSCLIENTS BUILDENV OPTIONS INTEGRITY_CHECK MAN_DIRS
	             DOC_DIRS PURGE_TARGETS COMPRESSGZ COMPRESSBZ2 COMPRESSXZ
	             COMPRESSLRZ COMPRESSLZO COMPRESSZ)
	local string=(CARCH CHOST CPPFLAGS CFLAGS CXXFLAGS RUSTFLAGS LDFLAGS DEBUG_CFLAGS
	              DEBUG_CXXFLAGS DEBUG_RUSTFLAGS DISTCC_HOSTS BUILDDIR STRIP_BINARIES
	              STRIP_SHARED STRIP_STATIC PKGDEST SRCDEST SRCPKGDEST LOGDEST PACKAGER
	              GPGKEY PKGEXT SRCEXT)

	local i keys ret=0

	# global variables
	for i in ${array[@]}; do
 	eval "keys=(\"\${!$i[@]}\")"
		if (( ${#keys[*]} > 0 )); then
			if ! is_array $i; then
				error "$(gettext "%s should be an array")" "$i"
				ret=1
			fi
		fi
	done

	for i in ${string[@]}; do
		eval "keys=(\"\${!$i[@]}\")"
		if (( ${#keys[*]} > 0 )); then
			if is_array $i; then
				error "$(gettext "%s should not be an array")" "$i"
				ret=1
			fi
		fi
	done

	return $ret
}
