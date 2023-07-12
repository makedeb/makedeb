#!/bin/bash
#
#   integrity.sh - functions relating to source integrity checking
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

[[ -n "$LIBMAKEPKG_INTEGRITY_SH" ]] && return
LIBMAKEPKG_INTEGRITY_SH=1

source "${LIBRARY:-'/usr/share/makepkg'}/util/message.sh"

for lib in "$LIBRARY/integrity/"*.sh; do
	source "$lib"
done

check_source_integrity() {
	if (( SKIPCHECKSUMS && SKIPPGPCHECK )); then
		warning "$(gettext "Skipping all source file integrity checks.")"
	elif (( SKIPCHECKSUMS )); then
		warning "$(gettext "Skipping verification of source file checksums.")"
		check_pgpsigs "$@"
	elif (( SKIPPGPCHECK )); then
		warning "$(gettext "Skipping verification of source file PGP signatures.")"
		check_checksums "$@"
	else
		check_checksums "$@"
		check_pgpsigs "$@"
	fi
}
