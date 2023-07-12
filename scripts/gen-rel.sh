#!/usr/bin/env bash


# Make sure needed software is installed.
for prgm in curl jq; do
	if ! type -t "${prgm}" 1> /dev/null; then
		error "Program '${prgm}' isn't installed."
		failed_checks=1
	fi
done


declare sourcefile="${sourcefile:-scripts/versions.sh}"

new_pkgver="$(cat .data.json | jq -r '.current_pkgver')"
releases="$(curl 'https://api.github.com/repos/makedeb/makedeb/releases?per_page=100' | jq -r '.[].name')"
export new_pkgver
export releases
declare -p new_pkgver > "${sourcefile}"
declare -p releases >> "${sourcefile}"
