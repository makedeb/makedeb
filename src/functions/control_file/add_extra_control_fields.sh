add_extra_control_fields() {
  local output_file="${1}"

  if [[ "${control_fields}" != "" && "${skip_pkgbuild_control_fields}" != "true" ]]; then
    add_extra_control_fields_template "control_fields" "${output_file}"
  fi

  if [[ "${extra_control_fields}" != "" ]]; then
    add_extra_control_fields_template "extra_control_fields" "${output_file}"
  fi
}
