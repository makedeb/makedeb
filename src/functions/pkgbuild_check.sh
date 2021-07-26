pkgbuild_check() {

	# Make sure variables are set
    for i in pkgname pkgver pkgrel; do
        if [[ "$(eval echo \${${i}})" == "" ]]; then
            error "${i} isn't set"
            bad_build_file="true"
        fi
    done

	# Check that 'control_fields' is an array (only check when '-Q' wasn't specified)
	if [[ "${skip_pkgbuild_control_fields}" != "true" && "${control_fields}" != "" ]]; then

		if ! declare -p control_fields 2> /dev/null | grep -q '^declare \-a'; then
			error 'control_fields should be an array'
			bad_build_file="true"
			exit 1
		fi

	fi

	# Check for duplicate control field names
	if [[ "${skip_pkgbuild_control_fields}" != "true" ]]; then
		check_for_duplicate_control_field_names ${control_fields[@]@Q} ${extra_control_fields[@]@Q}

	else
		check_for_duplicate_control_field_names ${extra_control_fields[@]@Q}

	fi

	# Checks (from PKGBUILD) for control fields makedeb uses, and makes sure
	# control fields don't contain spaces (again, only check when '-Q' isn't specified).
    if [[ "${skip_pkgbuild_control_fields}" != "true" && "${control_fields}" != "" ]]; then

		number=0
		local control_field_string="$(eval echo "\${control_fields[$number]}")"

		while [[ "${control_field_string}" != "" ]]; do

			check_for_bad_control_field_names "${control_field_string}" '[PKGBUILD]'

			number="$(( "${number}" + 1 ))"
			local control_field_string="$(eval echo "\${control_fields[$number]}")"

		done

	fi

	# Checks (from '-H' and '--field' options) for control fields makedeb uses,
	# and makes sure control fields don't contain spaces
	number=0
	local control_field_string="$(eval echo "\${extra_control_fields[$number]}")"

	while [[ "${control_field_string}" != "" ]]; do

		check_for_bad_control_field_names "${control_field_string}" '[-H/--field]'

		number="$(( "${number}" + 1 ))"
		local control_field_string="$(eval echo "\${extra_control_fields[$number]}")"

	done

	# Exit if anything above produced an error.
	if [[ "${bad_control_fields}" == "true" ]]; then
		exit 1
	fi
}
