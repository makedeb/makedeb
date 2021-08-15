get_apt_output() {
  local starting_line="${2}" \
        returned_variable="${1}" \
        returned_packages="" \
        returned_packages_temp="" \
        check_packages=0

  while IFS="" read -r line; do
    # If 'check_packages' is triggered, start processing lines until a line
    # without a space prefix is encountered.
    if (( "${check_packages}" )); then
      if echo "${line}" | grep -q '^ '; then
        if [[ "${returned_variable}" == "bad_apt_dependencies" ]]; then
          returned_packages+="${line}\n"
        else
          returned_packages+="${line} "
        fi
      else
        break
      fi
    elif echo "${line}" | grep -q "${starting_line}"; then
      check_packages=1
    fi
  done < <(echo "${apt_output}")

  returned_packages=("$(echo "${returned_packages}" | tr -s ' ' | sed -e 's|^ ||' -e 's| $||')")

  declare -gn "variable_ref=${returned_variable}"
  declare -g variable_ref=(${returned_packages[@]})
}
