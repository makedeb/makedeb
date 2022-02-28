get_variables() {
  mapfile -t pkginfo_data < <(cat .PKGINFO)

  if [[ "${1}" != "" ]]; then
    printf '%s\n' "${pkginfo_data[@]}" | grep "${1} =" | awk -F ' = ' '{print $2}' | xargs
    return
  fi

  # Process variables.
  for i in pkgname pkgver pkgdesc url arch license provides replaces backup; do
    local returned_array=()

    # Get field values
    for j in "${pkginfo_data[@]}"; do
      string_value="$(echo "${j}" | grep "^${i} =" | awk -F ' = ' '{print $2}')" || true

      if [[ "${string_value}" != "" ]]; then
        returned_array+=("${string_value}")
      fi
    done

    create_array "${i}" "${returned_array[@]}"
  done

  # We process these under a separate key, as the PKGINFO file removes the
  # leading 's' from them.
  for i in depends optdepends conflicts; do
    local string="$(echo "${i}" | sed 's|.$||')"
    local returned_array=()

    # Get field values
    for j in "${pkginfo_data[@]}"; do
      string_value="$(echo "${j}" | grep "^${string} =" | awk -F ' = ' '{print $2}')" || true

      if [[ "${string_value}" != "" ]]; then
        returned_array+=("${string_value}")
      fi
    done

    create_array "${i}" "${returned_array[@]}"
  done
}
