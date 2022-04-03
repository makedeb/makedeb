lint_pkgbuild_functions+=('get_maintainers')

get_maintainers() {
	mapfile -t maintainer < <(cat "${BUILDFILE}" | grep '^# Maintainer: ' | sed 's|^# Maintainer: ||')

	if [[ "${#maintainer[@]}" -gt 1 ]]; then
		error "$(gettext "More than one maintainer was specified.")"
		return 1
	fi

	declare -r maintainer
}
