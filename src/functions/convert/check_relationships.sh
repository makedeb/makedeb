check_relationships() {
  set -- "${@}"

  local package_array=() \
        symbol_type \
        old_symbol_type \
        relationship_package_name \
        relationship_package_version \
        dependency_name

  for i in "${@:2}"; do
    if echo "${i}" | grep -E '<|<=|=|>=|>' &> /dev/null; then

      # Check what kind of dependency relationship symbol is used
      for j in '<=' '>=' '<' '>' '='; do
        if echo "${i}" | grep "${j}" &> /dev/null; then
          symbol_type="${j}"

          # Check if $symbol_type is '<' or '>'
          if [[ "$(echo "${symbol_type}" | wc -c)" == "2" && "$(echo "${symbol_type}" | grep -Evw '<|>')" == "" ]]; then
            old_symbol_type="${j}"
            symbol_type+="${j}"
          else
            old_symbol_type="${symbol_type}"
          fi

          break
        fi
      done

      # Get values from left and right of symbol (package name and package version)
      relationship_package_name=$(echo "${i}" | awk -F "${old_symbol_type}" '{print $1}')
      relationship_package_version=$(echo "${i}" | awk -F "${old_symbol_type}" '{print $2}')

      # Add parenthesis if dependency has a relationship
      dependency_name="$(echo "${relationship_package_name}(${symbol_type}${relationship_package_version})")"
      package_array+=("${dependency_name}")

    else
      package_array+=("${i}")
    fi

  done

  create_array "${1}" "${package_array[@]}"
}
