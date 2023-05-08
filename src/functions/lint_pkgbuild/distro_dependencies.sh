lint_pkgbuild_functions+=('lint_distro_dependencies')

# Prevent distro/arch variables from pairing up with other distro/arch variables in variable names, as it makes it easy for our parser to get confused.
lint_distro_dependencies() {
	local var
	local matches
	local match

	for var in "${pkgbuild_schema_arch_arrays[@]}"; do
		mapfile -t matches < <(printf '%s\n' "${env_keys[@]}" | grep "${var}_${var}" | head -c -1)

		for match in "${matches[@]}"; do
			error "$(gettext "Variable '%s' is not allowed to appear in PKGBUILDs.")" "${match}"
		done
	done
}
