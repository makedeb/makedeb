#!/bin/bash
#
#   pkgname.sh - Check the 'pkgname' variable conforms to requirements.
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

[[ -n "$LIBMAKEPKG_LINT_PKGBUILD_PKGNAME_SH" ]] && return
LIBMAKEPKG_LINT_PKGBUILD_PKGNAME_SH=1

source "${LIBRARY:-'/usr/share/makepkg'}/util/message.sh"


lint_pkgbuild_functions+=('lint_pkgname')


lint_one_pkgname() {
	local name="${1}"
	local type="${2}"
	local ret=0

	if [[ -z $name ]]; then
		error "$(gettext "%s is not allowed to be empty.")" "$type"
		return 1
	fi
	
	if [[ ${name:0:1} = "-" ]]; then
		error "$(gettext "%s is not allowed to start with a hyphen.")" "$type"
		ret=1
	fi
	
	if [[ ${name:0:1} = "." ]]; then
		error "$(gettext "%s is not allowed to start with a dot.")" "$type"
		ret=1
	fi
	
	if [[ $name = *[![:ascii:]]* ]]; then
		error "$(gettext "%s may only contain ascii characters.")" "$type"
		return 1
	fi
	
	# These first two need to be put into 'depends.sh' and 'optdepends.sh' respectively.
	if [[ "${type}" == "optdepends" ]]; then
		if ! check_prefix prefix "${name}" 'r!' 's!'; then
			error "$(gettext "%s contains an invalid prefix: '%s'")" "${type}" "${prefix}"
			return 1
		fi
		strip_prefix name "${name}"
	
	elif [[ "${type}" == "pkgname" || "${type}" == "pkgbase" ]]; then
		if [[ "${name}" =~ [A-Z] ]]; then
			error "'${type}' contains capital letters"
			ret=1
		fi
	fi
	
	if [[ $name = *[^[:alnum:]+_.@-]* ]]; then
		error "$(gettext "%s contains invalid characters: '%s'")" \
				"$type" "${name//[[:alnum:]+_.@-]}"
		ret=1
	fi

	return $ret
}

lint_pkgname() {
	local ret=0 i

	if [[ -z ${pkgname[@]} ]]; then
		error "$(gettext "%s is not allowed to be empty.")" "pkgname"
		ret=1
	else
		for i in "${pkgname[@]}"; do
			lint_one_pkgname "$i" 'pkgname' || ret=1
		done
	fi

	return $ret
}

check_prefix() {
	local return_variable="${1}"
	local variable_data="${2}"
	local variable_prefixes=("${@:3}")
	local ret=1
	
	local variable_prefix="$(echo "${variable_data}" | sed 's|[^!]*$||')"
	
	if [[ "${variable_prefix}" == "" ]]; then
		ret=0
	else
		for i in "${variable_prefixes[@]}"; do
			if [[ "${i}" == "${variable_prefix}" ]]; then
				ret=0
			fi
		done
	fi

	if [[ "${ret}" != "0" ]]; then
		declare -g "${return_variable}=${variable_prefix}"
	fi
	
	return "${ret}"
}

strip_prefix() {
	local return_variable="${1}"
	local variable_data="${2}"
	local prefix=""
	
	prefix="$(echo "${variable_data}" | sed 's|[^!]*$||')"
	variable_data="$(echo "${variable_data}" | sed "s|^${prefix}||")"
	
	printf -v "${return_variable}" "${variable_data}"
}
