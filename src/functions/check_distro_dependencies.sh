check_distro_dependencies() {
  local distro_version="$(lsb_release -cs)" \
        variable_ref="" \
        package_data=""

  for i in depends optdepends conflicts provides replaces makedepends optdepends; do
    eval package_data=("\"\${${distro_version}_${i}[@]}\"")

    if [[ "${package_data}" != "" ]]; then
      eval declare -g "${i}=(\"\${package_data[@]}\")"
    fi
  done
}
