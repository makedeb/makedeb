add_extra_control_fields_template() {
  # We set 'number' by itself as it otherwise won't have been set for 'control_string'.
  local number=0
  local control_string="${1}[${number}]"
  local control_string="${!control_string}"
  local output_file="${2}"

  while [[ "${control_string}" != "" ]]; do
    number="$(( "${number}" + 1 ))"

    control_string_name="$(echo "${control_string}" | grep -o '^[^:]*')"
    control_string_value="$(echo "${control_string}" | sed 's|^[^:]*: ||')"

    (( "${hide_control_output}" )) ||  msg2 "Adding field '${control_string_name}' to control file..."
    export_control "${control_string_name}:" "${output_file}" "${control_string_value}"

    local control_string="${1}[${number}]"
    local control_string="${!control_string}"
  done
}
