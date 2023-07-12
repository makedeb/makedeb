#!/bin/bash
#
#   generate_signature.sh - functions for generating PGP signatures
#
#   Copyright (c) 2008-2021 Pacman Development Team <pacman-dev@archlinux.org>
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

[[ -n "$LIBMAKEPKG_INTEGRITY_GENERATE_SIGNATURE_SH" ]] && return
LIBMAKEPKG_INTEGRITY_GENERATE_SIGNATURE_SH=1

source "${LIBRARY:-'/usr/share/makepkg'}/util/message.sh"

create_signature() {
	local ret=0
	local filename="$1"

	local SIGNWITHKEY=()
	if [[ -n $GPGKEY ]]; then
		SIGNWITHKEY=(-u "${GPGKEY}")
	fi

	gpg --detach-sign --use-agent "${SIGNWITHKEY[@]}" --no-armor "$filename" &>/dev/null || ret=$?


	if (( ! ret )); then
		msg2 "$(gettext "Created signature file %s.")" "${filename##*/}.sig"
	else
		warning "$(gettext "Failed to sign package file %s.")" "${filename##*/}"
	fi

	return $ret
}

create_package_signatures() {
	local ret=0

	if [[ $SIGNPKG != 'y' ]]; then
		return 0
	fi
	local pkg pkgarch pkg_file
	local fullver=$(get_full_version)

	msg "$(gettext "Signing package(s)...")"

	for pkg in "${pkgname[@]}"; do
		pkgarch=$(get_pkg_arch $pkg)
		pkg_file="$PKGDEST/${pkg}-${fullver}-${pkgarch}${PKGEXT}"

		create_signature "$pkg_file" || ret=$?
	done

	# check if debug package needs a signature
	if check_option "debug" "y" && check_option "strip" "y"; then
		pkg=$pkgbase-debug
		pkgarch=$(get_pkg_arch)
		pkg_file="$PKGDEST/${pkg}-${fullver}-${pkgarch}${PKGEXT}"
		if [[ -f $pkg_file ]]; then
			create_signature "$pkg_file" || ret=$?
		fi
	fi

	return $ret
}
