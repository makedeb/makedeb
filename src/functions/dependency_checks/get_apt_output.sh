get_apt_output() {
  local starting_line="${2}" \
        returned_variable="${1}" \
        returned_packages="" \
        returned_packages_temp="" \
        check_packages=0

  mapfile -t arrayed_apt_output < <(echo "${apt_output}")

  for i in "${arrayed_apt_output[@]}"; do
    # If 'check_packages' is triggered, start processing lines until a line
    # without a space prefix is encountered.
    if (( "${check_packages}" )); then
      if echo "${i}" | grep -q '^ '; then
        if [[ "${returned_variable}" == "bad_apt_dependencies" ]]; then
          returned_packages+="${i}\n"
        else
          returned_packages+="${i} "
        fi
      else
        break
      fi
    elif echo "${i}" | grep -q "${starting_line}"; then
      check_packages=1
    fi
  done

  returned_packages=($(echo "${returned_packages}" | tr -s ' ' | sed -e 's|^ ||' -e 's| $||'))

  create_array "${returned_variable}" "${returned_packages[@]}"
}
