#!/bin/bash
[[ -n "$LIBMAKEPKG_LINT_PKGBUILD_OPTIONS_SH" ]] && return
LIBMAKEPKG_LINT_PKGBUILD_OPTIONS_SH=1

LIBRARY=${LIBRARY:-'/usr/share/makepkg'}

source "$LIBRARY/util/message.sh"


lint_pkgbuild_functions+=('lint_extensions')

lint_extensions() {
	local extension
	local ret=0

	for extension in "${extensions[@]}"; do
		invalid_characters="$(echo "${extension}" | grep -o '[^a-zA-Z0-9-]' | sort -u | tr -d '\n')"

		if [[ "${#invalid_characters}" -gt 0 ]]; then
			error "$(gettext "'%s' under '%s' contains invalid characters: '%s'.")" "${extension}" 'extensions' "${invalid_characters}"
			ret=1
		fi
	done

	return "${ret}"
}
