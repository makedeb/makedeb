remove_optdepends_description() {
        local target_var="${1}"
        local values=("${@:2}")
	local target_values=()
	local value
	local new_value

	for value in "${values[@]}"; do
		new_value="$(echo "${value}" | grep -o '^[^:]*')"
		target_values+=("${new_value}")
	done

	create_array "${target_var}" "${target_values[@]}"
}
