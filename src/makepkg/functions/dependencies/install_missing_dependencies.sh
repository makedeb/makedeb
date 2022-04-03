install_missing_dependencies() {
    if [[ "${#missing_dependencies}" == "0" && "${#missing_build_dependencies}" == "0" ]]; then
        return 0
    fi

    msg2 "Installing required build dependencies..."

    if [[ "${target_os}" == "debian" ]]; then
        if ! sudo apt-get satisfy "${apt_args[@]}" -- "${missing_dependencies[@]}" "${missing_build_dependencies[@]}"; then
            error "There was an error installing build dependencies."
            exit 1
        fi

        if ! sudo apt-mark auto -- "${missing_dependencies_no_relations[@]}" "${missing_build_dependencies_no_relations[@]}" 1> /dev/null; then
            error "There was an error marking installed build dependencies as automatically installed."
            error "You may need to mark the following packages as automatically installed via 'apt-mark auto':"

            for i in "${missing_dependencies_no_relations[@]}" "${missing_build_dependencies_no_relations[@]}"; do
                msg2 "${i}"
            done

            exit 1
        fi

    elif [[ "${target_os}" == "arch" ]]; then
        if ! sudo pacman -S --asdeps "${pacman_args[@]}" -- "${missing_dependencies[@]}" "${missing_build_dependencies[@]}"; then
            error "There was an error installing build dependencies."
            exit 1
        fi
    fi
}

# vim: set syntax=bash ts=4 sw=4 expandtab:
