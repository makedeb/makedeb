install_depends() {
  local failed_dependency_installation=0

  if [[ "${#needed_dependencies_temp}" != "0" ]]; then
    msg2 "Installing build dependencies..."

    # Remove all packages in 'needed_dependencies' that match package names
    # in 'pkgname'.
    for i in "${needed_dependencies_temp[@]}"; do
      for j in "${pkgname[@]}"; do
        if [[ "${i}" != "${j}" ]]; then
          needed_dependencies+=("${i}")
        fi
      done
    done

    # Set needed_dependencies to be global and readonly, as we'll use it later
    # in remove_dependencies() if the '-r' option was passed.
    declare -gr needed_dependencies

    # Return if new dependency list is equal to 0, as we have nothing to
    # install then.
    if [[ "${#needed_dependencies}" == "0" ]]; then
      return
    fi

    # Install build dependencies, and mark them as automatically installed.
    eval sudo apt-get install -- ${needed_dependencies[@]@Q} || failed_dependency_installation=1
    eval sudo apt-mark auto -- ${needed_dependencies[@]@Q} 1> /dev/null || failed_dependency_installation=1

    if (( "${failed_dependency_installation}" )); then
      error "There was an error installing build dependencies."
      exit 1
    fi
  fi
}
