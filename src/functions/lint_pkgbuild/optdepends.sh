#!/bin/bash
#
#   optdepends.sh - Check the 'optdepends' array conforms to requirements.
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

[[ -n "$LIBMAKEPKG_LINT_PKGBUILD_OPTDEPENDS_SH" ]] && return
LIBMAKEPKG_LINT_PKGBUILD_OPTDEPENDS_SH=1

source "${LIBRARY:-'/usr/share/makepkg'}/lint_pkgbuild/fullpkgver.sh"
source "${LIBRARY:-'/usr/share/makepkg'}/lint_pkgbuild/pkgname.sh"
source "${LIBRARY:-'/usr/share/makepkg'}/util/message.sh"
source "${LIBRARY:-'/usr/share/makepkg'}/util/pkgbuild.sh"


lint_pkgbuild_functions+=('lint_optdepends')


lint_optdepends() {
	lint_deps 'optdepends' 'r s' || return 1
}
