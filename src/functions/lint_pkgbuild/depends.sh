#!/bin/bash
#
#   depends.sh - Check the 'depends' array conforms to requirements.
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

[[ -n "$LIBMAKEPKG_LINT_PKGBUILD_DEPENDS_SH" ]] && return
LIBMAKEPKG_LINT_PKGBUILD_DEPENDS_SH=1

for i in pkgname fullpkgver; do
    source "${LIBRARY:-'/usr/share/makepkg'}/lint_pkgbuild/${i}.sh"
done
for i in message pkgbuild; do
    source "${LIBRARY:-'/usr/share/makepkg'}/util/${i}.sh"
done

lint_pkgbuild_functions+=('lint_depends')

lint_depends() {
	lint_deps 'depends' 'p' || return 1
}

lint_deps() {
	local multiarch_vars=('depends' 'makedepends' 'checkdepends' 'optdepends' 'provides')
	local ret=0
	local var="${1}"
	local valid_prefixes
	local depends_var_list
	local depends_list
	local deps
	local prefix
	local name
	local name_no_arch
	local restrictor
	local ver
	local i
	local j
	local k
	local pkg_epoch
	local pkg_pkgver
	local pkg_pkgrel

	mapfile -t depends_var_list < <(get_extended_variables "${var}")
	mapfile -t valid_prefixes < <(echo "${2}" | sed 's| |\n|g' | head -c -1)

	for i in "${depends_var_list[@]}"; do
		depends_list="${i}[@]"
		depends_list=("${!depends_list}")

		for j in "${depends_list[@]}"; do
			prefix="$(echo "${j}" | grep '!' | grep -o '^[^!]*')"

			if [[ "$(echo "${j}" | grep -o '!' | wc -l)" -gt 1 ]]; then
				error "$(gettext "Dependency '%s' under '%s' contains more than one '!'.")" "${j}" "${i}"
				ret=1
				continue
			fi
			
			if [[ "${prefix}" != "" ]] && ! in_array "${prefix}" "${valid_prefixes[@]}"; then
				error "$(gettext "Dependency '%s' under '%s' contains an invalid prefix: '%s'")" "${j}" "${i}" "${prefix}"
				ret=1
			fi

			j="$(echo "${j}" | sed 's|^[^!]*!||')"
			mapfile -t deps < <(split_dep_by_pipe "${j}")

			for k in "${deps[@]}"; do
				if [[ "${var}" == "optdepends" ]]; then
					k="$(echo "${k}" | sed 's|: .*||')"
				fi

				name="$(echo "${k}" | grep -o '^[^<>=]*')"
				name_no_arch="$(echo "${name}" | sed 's|:.*||')"
				mapfile -t restrictor < <(echo "${k}" | grep -Eo '<=|>=|=|<|>')
				ver="$(echo "${k}" | grep -o '[<>=].*$' | sed -E 's/<=|>=|=|<|>//')"

				if [[ "${#restrictor[@]}" == 2 ]]; then
					error "$(gettext "More than one version restrictor was specified for %s: %s")" "${k@Q}" "${restrictor[*]@Q}"
					ret=1
					continue
				fi
				
				if in_array "${var}" "${multiarch_vars[@]}"; then
					if [[ "$(echo "${name}" | grep -o ':' | wc -l)" -gt 1 ]]; then
						error "$(gettext "Package dependency '%s' contains more than one ':'.")" "${name}"
						ret=1
					fi

					lint_one_pkgname "${name_no_arch}" "${j}" || ret=1
				else
					lint_one_pkgname "${name}" "${j}" || ret=1
				fi
				
				if [[ "${ver}"  != "" ]]; then
					split_version "${ver}" pkg_epoch pkg_pkgver pkg_pkgrel

					if [[ "${pkg_epoch:+x}" == "x" ]]; then
						check_epoch "${pkg_epoch}" "${k}" || ret=1
					fi

					check_pkgver "${pkg_pkgver}" "${k}" || ret=1

					if [[ "${pkg_pkgrel:+x}" == "x" ]]; then
						check_pkgrel "${pkg_pkgrel}" "${k}" || ret=1
					fi
				fi

				if [[ "${var}" == "provides" ]] && [[ "${restrictor+x}" == "x" ]] && [[ "${restrictor}" != "=" ]]; then
					error "$(gettext "Version restrictor %s in %s isn't allowed on %s.")" "${restrictor@Q}" "${k@Q}" "${var@Q}"
					ret=1
				fi
			done
		done
	done

	return $ret
}
