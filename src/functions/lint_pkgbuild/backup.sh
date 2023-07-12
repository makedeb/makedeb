#!/bin/bash
#
#   backup.sh - Check the 'backup' array conforms to requirements.
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

[[ -n "$LIBMAKEPKG_LINT_PKGBUILD_BACKUP_SH" ]] && return
LIBMAKEPKG_LINT_PKGBUILD_BACKUP_SH=1


for i in message pkgbuild; do
    source "${LIBRARY:-'/usr/share/makepkg'}/util/${i}.sh"
done

lint_pkgbuild_functions+=('lint_backup')


lint_backup() {
	local list name backup_list ret=0

	backup_list=("${backup[@]}")
	for name in "${pkgname[@]}"; do
		if extract_function_variable "package_$name" backup 1 list; then
			backup_list+=("${list[@]}")
		fi
	done

	for name in "${backup_list[@]}"; do
		if [[ ${name:0:1} != "/" ]]; then
			error "$(gettext "%s entry should start with a forward slash : %s")" "backup" "$name"
			ret=1
		fi
	done

	return $ret
}
