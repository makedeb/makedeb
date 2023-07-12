#!/bin/bash
#
#   source_date_epoch.sh - Check that reproducible builds timestamp is valid
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

[[ -n $LIBMAKEPKG_LINT_CONFIG_SOURCE_DATE_EPOCH_SH ]] && return
LIBMAKEPKG_LINT_CONFIG_SOURCE_DATE_EPOCH_SH=1

source "${LIBRARY:-'/usr/share/makepkg'}/util/message.sh"

lint_config_functions+=('lint_source_date_epoch')


lint_source_date_epoch() {
	if [[ $SOURCE_DATE_EPOCH = *[^[:digit:]]* ]]; then
		error "$(gettext "%s contains invalid characters: %s")" \
			"\$SOURCE_DATE_EPOCH" "${SOURCE_DATE_EPOCH//[[:digit:]]}"
		return 1
	fi
}
