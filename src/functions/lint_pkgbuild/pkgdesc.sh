lint_pkgbuild_functions+=('lint_pkgdesc')

lint_pkgdesc() {
    if [[ "${pkgdesc-x}" == "x" ]]; then
        error "$(gettext "pkgdesc must be set.")"
        return 1
    fi

    if [[ "${pkgdesc}" == "" ]]; then
	error "$(gettext "pkgdesc cannot be empty.")"
	return 1
    fi

    if echo "${pkgdesc}" | grep -q '^[ ]*$'; then
	error "$(gettext "pkgdesc must contain characters other than spaces.")"
	return 1
    fi
}

# vim: set sw=4 expandtab:
