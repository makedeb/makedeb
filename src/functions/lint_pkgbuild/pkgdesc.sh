lint_pkgbuild_functions+=('lint_pkgdesc')

lint_pkgdesc() {
    # See if the pkgdesc variable was set.
    if [[ "${pkgdesc:+x}" != "x" ]]; then
	return 0
    fi
    
    # Check pkgdesc requirements.
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
