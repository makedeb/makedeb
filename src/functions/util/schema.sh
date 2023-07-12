#!/bin/bash
#
#   schema.sh - declare specific groups of pkgbuild variables
#
#   Copyright (c) 2015-2021 Pacman Development Team <pacman-dev@archlinux.org>
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

[[ -n "$LIBMAKEPKG_SCHEMA_SH" ]] && return
LIBMAKEPKG_SCHEMA_SH=1

source "${LIBRARY:-'/usr/share/makepkg'}/util/util.sh"


known_hash_algos=({ck,md5,sha{1,224,256,384,512},b2})

pkgbuild_schema_arrays=(arch backup checkdepends conflicts depends groups
                        license makedepends noextract optdepends options
                        provides replaces source validpgpkeys control_fields
                        "${known_hash_algos[@]/%/sums}")

pkgbuild_schema_strings=(changelog epoch install preinst postinst prerm postrm
                         pkgbase pkgdesc pkgrel pkgver url)

# This actually works for both architecture and dependency variable extensions now - we just haven't renamed it so we can still be compatible with previous code.
pkgbuild_schema_arch_arrays=(checkdepends conflicts depends makedepends
                             optdepends provides replaces source control_fields
                             "${known_hash_algos[@]/%/sums}")

pkgbuild_schema_arch_strings=(preinst postinst prerm postrm)

pkgbuild_schema_package_overrides=(pkgdesc arch url license groups depends
                                   optdepends provides conflicts replaces
                                   backup options install preinst postinst
                                   prerm postrm changelog control_fields
                                   pkgarch multiarch)

readonly -a known_hash_algos pkgbuild_schema_arrays \
	pkgbuild_schema_strings pkgbuild_schema_arch_arrays \
	pkgbuild_schema_package_overrides pkgbuild_schema_arch_strings
