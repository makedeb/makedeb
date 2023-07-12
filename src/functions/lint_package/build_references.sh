#!/bin/bash
#
#   build_references.sh - Warn about files containing references to build directories
#
#   Copyright (c) 2013-2021 Pacman Development Team <pacman-dev@archlinux.org>
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

[[ -n "$LIBMAKEPKG_LINT_PACKAGE_BUILD_REFERENCES_SH" ]] && return
LIBMAKEPKG_LINT_PACKAGE_BUILD_REFERENCES_SH=1

source "${LIBRARY:-'/usr/share/makepkg'}/util/message.sh"

lint_package_functions+=('warn_build_references')

warn_build_references() {
	local refs

	for var in srcdir pkgdir; do
		mapfile -t refs < <(find "$pkgdir" -type f -exec grep -l "${!var}" {} +)
		if  (( ${#refs} > 0 )); then
			warning "$(gettext 'Package contains reference to %s')" "\$$var"
			printf '%s\n' "${refs[@]#"$pkgdir/"}" >&2
		fi
	done
	return 0
}
