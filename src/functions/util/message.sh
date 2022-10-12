#!/bin/bash
#
#   message.sh - functions for outputting messages in makepkg
#
#   Copyright (c) 2006-2021 Pacman Development Team <pacman-dev@archlinux.org>
#   Copyright (c) 2002-2006 by Judd Vinet <jvinet@zeroflux.org>
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

[[ -n "$LIBMAKEPKG_UTIL_MESSAGE_SH" ]] && return
LIBMAKEPKG_UTIL_MESSAGE_SH=1


colorize() {
	# prefer terminal safe colored and bold text when tput is supported
	if tput setaf 0 &>/dev/null; then
		ALL_OFF="$(tput sgr0)"
		BOLD="$(tput bold)"
		BLUE="${BOLD}$(tput setaf 4)"
		GREEN="${BOLD}$(tput setaf 2)"
		RED="${BOLD}$(tput setaf 1)"
		YELLOW="${BOLD}$(tput setaf 3)"
		PURPLE="${BOLD}$(tput setaf 5)"
	else
		ALL_OFF="\e[0m"
		BOLD="\e[1m"
		BLUE="${BOLD}\e[34m"
		GREEN="${BOLD}\e[32m"
		RED="${BOLD}\e[31m"
		YELLOW="${BOLD}\e[33m"
		PURPLE="${BOLD}\e[35m"
	fi
	readonly ALL_OFF BOLD BLUE GREEN RED YELLOW
}

# plainerr/plainerr are primarily used to continue a previous message on a new
# line, depending on whether the first line is a regular message or an error
# output

plain() {
	(( QUIET )) && return
	local mesg=$1; shift
	printf "${BOLD}    ${mesg}${ALL_OFF}\n" "$@"
}

plainerr() {
	plain "$@" >&2
}

# Pass in the 'MSG_PREFIX' variable when calling these functions to get a prefix on your text. I.e:
# MSG_PREFIX=' gimp' msg hi
#     [# gimp] hi
#
# Please put a space before your prefix.
msg() {
	(( QUIET )) && return
	local mesg=$1; shift
	printf "${GREEN}[#${MSG_PREFIX}]${ALL_OFF}${BOLD} ${mesg}${ALL_OFF}\n" "$@"
}

msg2() {
	(( QUIET )) && return
	local mesg=$1; shift
	printf "${BLUE}  [->${MSG_PREFIX}]${ALL_OFF}${BOLD} ${mesg}${ALL_OFF}\n" "$@"
}

warning() {
	local mesg=$1; shift
	printf "${YELLOW}[!${MSG_PREFIX}]${ALL_OFF}${BOLD} ${mesg}${ALL_OFF}\n" "$@" >&2
}

warning2() {
	local mesg=$1; shift
  	printf "${YELLOW}  [->${MSG_PREFIX}]${ALL_OFF}${BOLD} ${mesg}${ALL_OFF}\n" "$@" >&2
}

error() {
	local mesg=$1; shift
	printf "${RED}[!${MSG_PREFIX}]${ALL_OFF}${BOLD} ${mesg}${ALL_OFF}\n" "$@" >&2
}

error2() {
  local mesg=$1; shift
  printf "${RED}  [->${MSG_PREFIX}]${ALL_OFF}${BOLD} ${mesg}${ALL_OFF}\n" "$@" >&2
}

question() {
	local mesg=$1; shift
	printf "${PURPLE}[?]${ALL_OFF}${BOLD} ${mesg}${ALL_OFF}" "${@}"
}