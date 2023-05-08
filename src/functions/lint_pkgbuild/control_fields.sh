lint_pkgbuild_functions+=('lint_control_fields')

lint_control_fields() {
	local ret=0
	local control_field_names=()
	local current_control_field
	local control_field_name
	local control_field_value
        declare -g MERGED_CONTROL_FIELDS=("${CONTROL_FIELDS[@]}")

	for control_field in "${control_fields[@]}"; do
		MERGED_CONTROL_FIELDS+=("${control_field}")
	done

	for control_field in "${MERGED_CONTROL_FIELDS[@]}"; do
		mapfile -t current_control_field < <(echo "${control_field}")

		if [[ "${#current_control_field[@]}" != 1 ]]; then
			error "Control field contains newlines."
			ret=1
			continue
		fi

		control_field_name="$(echo "${control_field}" | sed 's|:.*$||')"
		control_field_value="$(echo "${control_field}" | sed 's|^[^:]*: ?||')"

		matches="$(occurances_in_array "${control_field_name}" "${control_field_names[@]}")"

		if [[ "${matches}" != 0 ]]; then
			[[ "${matches}" == 1 ]] && error "$(gettext "Control field '%s' was found more than once.")" "${control_field_name}"
			ret=1
		fi

		control_field_names+=("${control_field_name}")
	done
        
	return "${ret}"
}

# vim: set sw=4 expandtab:
