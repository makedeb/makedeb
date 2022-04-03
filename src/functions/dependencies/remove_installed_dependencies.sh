remove_installed_dependencies() {
    if [[ "${#missing_build_dependencies_no_relations[@]}" == "0" ]]; then
        return 0
    fi

    msg "Removing installed build dependencies..."

    if ! sudo apt-get purge "${apt_args[@]}" -- "${missing_build_dependencies_no_relations[@]}"; then
        error "There was an error removing build dependencies."
        exit 1
    fi
    msg "Done."
}

# vim: set syntax=bash ts=4 sw=4 expandtab:
