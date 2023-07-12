#!/bin/bash
#
#   missing_backup.sh - Warn about missing files in the backup array
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

[[ -n "$LIBMAKEPKG_LINT_PACKAGE_MISSING_BACKUP_SH" ]] && return
LIBMAKEPKG_LINT_PACKAGE_MISSING_BACKUP_SH=1

source "${LIBRARY:-'/usr/share/makepkg'}/util/message.sh"

lint_package_functions+=('warn_missing_backup')

warn_missing_backup() {
	local file
	for file in "${backup[@]}"; do
		if [[ ! -f "${pkgdir}/${file}" ]]; then
			warning "$(gettext "%s entry file not in package : %s")" "backup" "$file"
		fi
	done
	return 0
}
