convert_relationships_parentheses() {
  for i in depends predepends recommends suggests conflicts makedepends checkdepends provides replaces; do
    local new_values=()
    var="${i}[@]"

    for j in "${!var}"; do
      current_value="$(echo "${j}" | sed 's|(| (|g' | sed -E 's/[<>=][<>=]|[<>=]/& /g')"
      new_values+=("${current_value}")
    done

    create_array "${i}" "${new_values[@]}"
  done
}
