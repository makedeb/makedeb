remove_installed_dependencies() {
  if [[ "${#missing_build_dependencies_no_relations[@]}" == "0" ]]; then
    return 0
  fi

  if [[ "${install_dependencies}" != "true" ]]; then
    warning "Build dependencies are being attempted to be removed, but weren't installed in this build run."
  fi
  
  msg "Removing installed build dependencies..."
  
  if [[ "${target_os}" == "debian" ]]; then
    if ! sudo apt-get purge "${apt_args[@]}" -- "${missing_build_dependencies_no_relations[@]}"; then
      error "There was an error removing build dependencies."
      exit 1
    fi
  
  elif [[ "${target_os}" == "arch" ]]; then
    if ! sudo pacman -R "${pacman_args[@]}" -- "${missing_build_dependencies_no_relations[@]}"; then
      error "There was an error removing build dependencies."
      exit 1
    fi
  fi
  msg "Done."
}
