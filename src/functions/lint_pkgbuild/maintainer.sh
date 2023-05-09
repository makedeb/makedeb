lint_pkgbuild_functions+=('get_maintainers')

get_maintainers() {
	mapfile -t maintainer < <(cat "${BUILDFILE}" | grep '^# Maintainer: ' | sed 's|^# Maintainer: ||')
	
	#if [[ "${#maintainer[@]}" == 0 ]]; then
	#	warning "$(gettext "A maintainer must be specified." )"
	#elif [[ "${#maintainer[@]}" -gt 1 ]]; then
	#	warning "$(gettext "More than one maintainer was specified.")"
	#	warning "$(gettext "Falling back to first maintainer '${maintainer[0]}'...")"
	#	maintainer="${maintainer[0]}"
	#fi

	declare -r maintainer
}
