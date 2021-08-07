generate_optdepends_fields() {
	recommends=()
	suggests=()

	for i in "${optdepends[@]}"; do
		string_value="${i/:*/}"
		
		declare string_prefix="$(echo "${string_value}" | grep -Eo 'r!|s!')"

		if [[ "${string_prefix}" == "" ]]; then
			suggests+=("${i}")
		else
			program_name="$(echo "${string_value}" | sed "s|^${string_prefix}||")"

			if [[ "${string_prefix}" == "r!" ]]; then
				recommends+=("${program_name}")
			elif [[ "${string_prefix}" == "s!" ]]; then
				suggests+="${program_name}"
			fi
		fi
	done
}
