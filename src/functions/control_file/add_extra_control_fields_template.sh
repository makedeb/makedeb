add_extra_control_fields_template() {
  local number=0 \
        control_string="$(eval echo \${${1}[$number]})" \
        output_file="${2}"

  while [[ "${control_string}" != "" ]]; do

    number="$(( "${number}" + 1 ))"

    control_string_name="$(echo "${control_string}" | grep -o '^[^:]*')"
    control_string_value="$(echo "${control_string}" | sed 's|^[^:]*: ||')"

    (( "${print_control}" )) ||  msg2 "Adding field '${control_string_name}' to control file..."
    export_control "${control_string_name}:" "${output_file}" "${control_string_value}"

    control_string="$(eval echo \${${1}[$number]})"

  done
}
