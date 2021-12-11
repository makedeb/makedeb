check_for_bad_control_field_names() {

  control_string_name="$(echo "${control_field_string}" | grep -o '^[^:]*')"

  # Make sure control field name isn't one that makedeb uses, as it would create duplicate entries
  local makedeb_control_fields=('Package' 'Description' 'Source' 'Version'
                                'Architecture' 'License' 'Maintainer'
                                'Depends' 'Suggests' 'Conflicts'
                                'Provides' 'Replaces' 'Breaks')

  for i in ${makedeb_control_fields[@]}; do

    if [[ "${control_string_name}" == "${i}" ]]; then
      error "${2} '${i}' is not allowed to be specified as a control field."
      bad_control_fields="true"
    fi

  done

  # Make make sure control field name doesn't contain spaces
  if [[ "$(echo "${control_string_name}" | awk -F ' ' '{print $2}')" != "" ]]; then
    error "${2} Control field '${control_field_string}' is invalid, as the name of the control field contains spaces."
    bad_control_fields="true"
  fi
}
