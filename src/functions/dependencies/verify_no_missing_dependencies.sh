verify_no_missing_dependencies() {
    if ! mapfile -t missing_deps < <(MAKEDEB="${0}" perl "${LIBRARY}/binary/missing_apt_dependencies.pl" "${@}"); then
		error "$(gettext "Failed to check missing dependencies.")"
		return 1
	fi
    
    if [[ "${#missing_deps[@]}" != 0 ]]; then
        error "The following build dependencies are missing:"

        for i in "${missing_deps[@]}"; do
            error2 "${i}"
        done

        return 1
    fi
}

# vim: set syntax=bash ts=4 sw=4 expandtab:
