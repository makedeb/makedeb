check_for_duplicate_control_field_names() {
  set -- ${@}

  number_of_control_fields="$#"

  # We only care about the name of control fields here
  # (i.e. only 'Package' in 'Package: hello-world'), so we remove anything
  # after the first colon (as well as the colon itself).
  local number=1
  local number_of_control_fields="$#"

  # Used in case it was accidentally set somewhere else
  unset control_fields_list

  while [[ "${number}" -le "${number_of_control_fields}" ]]; do
    local control_fields_list+=("$(echo "${!number}" | grep -o '^[^:]*'):")
    local number="$(( "${number}" + 1 ))"
done

  unset number

  local number=1

  while [[ "${number}" -le "${number_of_control_fields}" ]]; do
    local control_field_value="$(echo "${!number}" | grep -o '^[^:]*')"

    if [[ "$(echo -n "${control_fields_list[@]}" | sed 's|:|\n|g' | sed 's|^ ||' | grep "^${control_field_value}\$" | wc -l)" != "1" ]]; then

      # Only run commands for duplicates if the package hasen't already
      # been checked (as duplicates are going to end up being ran through
      # here multiple times). See the command below this if statement
      # for the list that the package gets added to when it *hasen't*
      # been checked yet.
      if [[ "$(echo "${found_control_field_duplicates[@]}" | sed 's|:|\n|g' | grep "^${control_field_value}\$")" == "" ]]; then
        error "Duplicate control fields for '${control_field_value}' were found."
        bad_control_fields="true"
      fi

      # Add duplicate to list so we don't output an error for it again
      local found_control_field_duplicates+=("${control_field_value}")

    fi

    local number="$(( "${number}" + 1 ))"
  done

}
