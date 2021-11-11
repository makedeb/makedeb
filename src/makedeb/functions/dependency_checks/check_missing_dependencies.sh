check_missing_dependencies() {
  # Get list of missing dependencies.
  if [[ "${target_os}" == "debian" ]]; then
    if ! missing_dependencies="$("${makedeb_utils_dir}/missing_apt_dependencies.py" "${predepends[@]}" "${depends[@]}")"; then
      error "There was an error checking build dependencies."
      exit 1
    elif ! missing_build_dependencies="$("${makedeb_utils_dir}/missing_apt_dependencies.py"  "${makedepends[@]}" "${checkdepends[@]}")"; then
      error "There was an error checking build dependencies."
      exit 1
    fi
        
  elif [[ "${target_os}" == "arch" ]]; then
    missing_dependencies="$(pacman -T -- "${predepends[@]}" "${depends[@]}")" || true
    missing_build_dependencies="$(pacman -T -- "${makedepends[@]}" "${checkdepends[@]}")" || true
  fi
  
  # Unset variables if no missing dependencies were found.
  for i in 'missing_dependencies' 'missing_build_dependencies'; do
    if [[ "${!i}" == "" ]]; then
      unset "${i}"
    fi
  done
    
  # Map output of commands to arrays.
  mapfile -t missing_dependencies < <(echo -n "${missing_dependencies}")
  mapfile -t missing_build_dependencies < <(echo -n "${missing_build_dependencies}")

  # Create dependency arrays without relationships attached (for when removing
  # build dependencies).
  declare missing_dependencies_no_relations=()
  declare missing_build_dependencies_no_relations=()
    
  for i in 'missing_dependencies' 'missing_build_dependencies'; do
    declare current_array=()
    declare var_string="${i}[@]"
            
    for j in "${!var_string}"; do
      declare current_program="$(echo "${j}" | sed -E 's/<.*|>.*|=.*//')"
      declare current_array+=("${current_program}")
    done
      
    create_array "${i}_no_relations" "${current_array[@]}"
    unset current_array
  done
      
  declare -g missing_dependencies
  declare -g missing_dependencies_no_relations=("${missing_dependencies_no_relations[@]}")
  declare -g missing_build_dependencies
  declare -g missing_build_dependencies_no_relations=("${missing_build_dependencies_no_relations[@]}")
}
