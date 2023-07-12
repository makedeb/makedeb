#!/bin/bash
#
#   install.sh - Check the files in the 'install' array exist.
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

[[ -n "$LIBMAKEPKG_LINT_PKGBUILD_INSTALL_SH" ]] && return
LIBMAKEPKG_LINT_PKGBUILD_INSTALL_SH=1

source "${LIBRARY:-'/usr/share/makepkg'}/util/message.sh"
source "${LIBRARY:-'/usr/share/makepkg'}/util/pkgbuild.sh"
source "${LIBRARY:-'/usr/share/makepkg'}/lint_pkgbuild/util.sh"


lint_pkgbuild_functions+=('lint_install')


lint_install() {
	local list file install_list ret=0

	install_list=("${install[@]}")
	# set pkgname the same way we do for running package(), this way we get
	# the right value in extract_function_variable
	local pkgname_backup=(${pkgname[@]})
	local pkgname
	for pkgname in "${pkgname_backup[@]}"; do
		extract_function_variable "package_$pkgname" install 0 file
		install_list+=("$file")
	done

	check_files_exist 'install' "${install_list[@]}" || ret=1

	return $ret
}
