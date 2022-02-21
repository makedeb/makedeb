verify_no_missing_dependencies() {
    if [[ "${#missing_dependencies[@]}" != "0" || "${#missing_build_dependencies[@]}" != "0" ]]; then
        error "The following build dependencies are missing:"

        for i in "${missing_dependencies[@]}" "${missing_build_dependencies[@]}"; do
            msg2 "${i}"
        done

        exit 1
    fi
}

# vim: set syntax=bash ts=4 sw=4 expandtab:
