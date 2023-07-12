#!/bin/bash
#
#   fullpkgver.sh - Check whether a full version conforms to requirements.
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

[[ -n "$LIBMAKEPKG_LINT_PKGBUILD_FULLPKGVER_SH" ]] && return
LIBMAKEPKG_LINT_PKGBUILD_FULLPKGVER_SH=1

for i in epoch pkgrel pkgver; do
    source "${LIBRARY:-'/usr/share/makepkg'}/lint_pkgbuild/${i}.sh"
done

check_fullpkgver() {
	local fullver=$1 type=$2
	local ret=0

	# If there are multiple colons or multiple hyphens, there's a
	# question of how we split it--it's invalid either way, but it
	# will affect error messages.  Let's mimic version.c:parseEVR().

	if [[ $fullver = *:* ]]; then
		# split at the *first* colon
		check_epoch "${fullver%%:*}" "$type" || ret=1
		fullver=${fullver#*:}
	fi

	# Since ver isn't allowed to be empty, don't let rel strip it
	# down to nothing.  Given "-XXX", "pkgver isn't allowed to
	# contain hyphens" is more helpful than "pkgver isn't allowed
	# to be empty".
	if [[ $fullver = ?*-* ]]; then
		# split at the *last* hyphen
		check_pkgrel "${fullver##*-}" "$type" || ret=1
		fullver=${fullver%-*}
	fi

	check_pkgver "$fullver" "$type" || ret=1

	return $ret
}
