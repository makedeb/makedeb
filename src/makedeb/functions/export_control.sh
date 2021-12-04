export_control() {
  local field_name="${1}" \
        output_file="${2}" \
        output_text=("${@:3}")

  if [[ ${output_text} != "" ]]; then
    echo "${1} ${output_text[@]}" 1>> "${output_file}"
  fi
}
