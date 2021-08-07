get_variables() {
  pkginfo="$(cat .PKGINFO)"

	if [[ "${1}" != "" ]]; then
		echo "${pkginfo}" | grep "${1} =" | awk -F ' = ' '{print $2}' | xargs
		return
	fi

	for i in pkgname pkgver pkgdesc url arch license provides replaces; do
		returned_array=()

		# Get field values
		while IFS= read -r line; do
			string_value="$(echo "${line}" | grep "^${i} =" | awk -F ' = ' '{print $2}')" || true

			if [[ "${string_value}" != "" ]]; then
				returned_array+=("${string_value}")
			fi

		done < <(echo "${pkginfo}")

		eval export "${i}=(${returned_array[@]@Q})"
	done

	for i in depends optdepends conflicts; do
		# Remove the 's' from the end of each string
    	local string=$(echo "${i}" | sed 's|.$||')

		local returned_array=()

		# Get field values
		while IFS= read -r line; do

			string_value="$(echo "${line}" | grep "^${string} =" | awk -F ' = ' '{print $2}')" || true

			if [[ "${string_value}" != "" ]]; then
				returned_array+=("${string_value}")
			fi
			
		done < <(echo "${pkginfo}")

		eval export "${i}=(${returned_array[@]@Q})"
	done
}
