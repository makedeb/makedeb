check_distro_dependencies() {
  local distro_version="$(lsb_release -cs)" \
        variable_ref="" \
        package_data=""

  # Skip checking of distribution dependencies if the system's codename isn't a
  # valid variable name.
  bad_variable_chars="$(echo "${distro_version}" | sed 's|^[a-zA-Z_][a-zA-Z0-9_]*||')"

  if [[ "${bad_variable_chars}" != "" ]]; then
    return
  fi

  # Continue with checking of variables.
  for i in depends optdepends conflicts provides replaces makedepends optdepends; do
    eval package_data=("\"\${${distro_version}_${i}[@]}\"")

    if [[ "${package_data}" != "" ]]; then
      eval declare -g "${i}=(\"\${package_data[@]}\")"
    fi
  done
}
