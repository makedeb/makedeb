check_missing_dependencies() {
    declare -g missing_dependencies=() \
               missing_build_dependencies=() \
               missing_dependencies_no_relations=() \
               missing_build_dependencies_no_relations=()

    # Get list of missing dependencies.
    if [[ "${target_os}" == "debian" ]]; then
        if ! mapfile -t missing_dependencies < <("${makedeb_utils_dir}/missing_apt_dependencies.py" "${predepends[@]}" "${depends[@]}"); then
            error "There was an error checking build dependencies."
            exit 1
        elif ! mapfile -t missing_build_dependencies < <("${makedeb_utils_dir}/missing_apt_dependencies.py"  "${makedepends[@]}" "${checkdepends[@]}"); then
            error "There was an error checking build dependencies."
            exit 1
        fi

    elif [[ "${target_os}" == "arch" ]]; then
        mapfile -t missing_dependencies < <(pacman -T -- "${predepends[@]}" "${depends[@]}") || true
        mapfile -t missing_build_dependencies < <(pacman -T -- "${makedepends[@]}" "${checkdepends[@]}") || true
    fi

    # Create dependency arrays without relationships attached (for when removing
    # build dependencies).
    declare -g missing_dependencies_no_relations=()
    declare -g missing_build_dependencies_no_relations=()

    for i in 'missing_dependencies' 'missing_build_dependencies'; do
        declare current_array=()
        declare var_string="${i}[@]"

        for j in "${!var_string}"; do
            declare current_program="$(echo "${j}" | grep -o '^[^ ]*')"
            declare current_array+=("${current_program}")
        done

        create_array "${i}_no_relations" "${current_array[@]}"
        unset current_array
    done
}

# vim: set syntax=bash ts=4 sw=4 expandtab:
