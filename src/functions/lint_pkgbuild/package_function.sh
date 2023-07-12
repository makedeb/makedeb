#!/bin/bash
#
#   package_function.sh - Check that required package functions exist.
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

[[ -n "$LIBMAKEPKG_LINT_PKGBUILD_PACKAGE_FUNCTION_SH" ]] && return
LIBMAKEPKG_LINT_PKGBUILD_PACKAGE_FUNCTION_SH=1

for i in message pkgbuild; do
    source "${LIBRARY:-'/usr/share/makepkg'}/util/${i}.sh"
done

lint_pkgbuild_functions+=('lint_package_function')


lint_package_function() {
	local i ret=0

	if (( ${#pkgname[@]} == 1 )); then
		if have_function 'package' && have_function "package_$pkgname"; then
			error "$(gettext "Conflicting %s and %s functions in %s")" "package()" "package_$pkgname()" "$BUILDFILE"
			ret=1
		elif have_function 'build' && ! { have_function 'package' || have_function "package_$pkgname"; }; then
			error "$(gettext "Missing %s function in %s")" "package()" "$BUILDFILE"
			ret=1
		fi
	else
		if have_function "package"; then
			error "$(gettext "Extra %s function for split package '%s'")" "package()" "$_pkgbase"
			ret=1
		fi
		for i in "${pkgname[@]}"; do
			if ! have_function "package_$i"; then
				error "$(gettext "Missing %s function for split package '%s'")" "package_$i()" "$i"
				ret=1
			fi
		done
	fi

	return $ret
}
