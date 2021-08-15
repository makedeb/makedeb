remove_dependencies() {
  local build_dependencies=() \
        build_dependency_list=()

  # Generate list of dependencies from 'depends' and 'makedepends'
  build_dependencies=("$(echo -n ${makedepends[@]} ${checkdepends[@]} | \
                        sed 's| |\n|g' | \
                        grep -o '^[^=<>]*' | \
                        tr -t '\n' ' ' | \
                        sed -e 's|^ ||' -e 's| $||')")

  # Only uninstall dependencies that were previously installed.
  # 'needed_dependencies' will contain dependencies from 'depends' as well,
  # so we remove any of those packages here by adding packages from
  # 'makedepends' and 'checkdepends' to a new list.
  for i in "${needed_dependencies[@]}"; do
    for j in "${build_dependencies[@]}"; do
      if [[ "${i}" == "${j}" ]]; then
        build_dependency_list+=("${i}")
      fi
    done
  done

  # Return if new dependency list is equal to 0, as we have nothing to
  # remove then.
  if [[ "${#build_dependency_list}" == "0" ]]; then
    return
  fi

  msg "Removing build dependencies..."
  eval sudo apt-get purge ${build_dependency_list[@]@Q}
}
