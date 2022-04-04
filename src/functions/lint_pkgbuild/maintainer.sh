lint_pkgbuild_functions+=('get_maintainers')

get_maintainers() {
	mapfile -t maintainer < <(cat "${BUILDFILE}" | grep '^# Maintainer: ' | sed 's|^# Maintainer: ||')
	
	if [[ "${#maintainer[@]}" == 0 ]]; then
		warning "$(gettext "A maintainer must be specified. This will be an error in a future release." )"
	elif [[ "${#maintainer[@]}" -gt 1 ]]; then
		warning "$(gettext "More than one maintainer was specified. This will be an error in a future release.")"
		warning "$(gettext "Falling back to first maintainer '${maintainer[0]}'...")"
		maintainer="${maintainer[0]}"
	fi

	declare -r maintainer
}
