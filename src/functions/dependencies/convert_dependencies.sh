convert_dependencies() {
    # Convert depends.
    local old_depends=("${depends[@]}")
    declare -g depends=()
    declare -g predepends=()

    for dep in "${old_depends[@]}"; do
	if echo "${dep}" | grep -q '^p!'; then
	    depname="$(echo "${dep}" | sed 's|^p!||')"
	    predepends+=("${depname}")
	else
	    depends+=("${dep}")
	fi
    done

    # Convert 'optdepends'.
    local old_optdepends=("${optdepends[@]}")
    unset optdepends
    declare -g recommends=()
    declare -g suggests=()

    for dep in "${old_optdepends[@]}"; do
        if echo "${dep}" | grep -Eq '^r!|^s!'; then
            prefix="$(echo "${dep}" | grep -o '^[a-z]!')"
            depname="$(echo "${dep}" | sed 's|^[a-z]!||')"
        else
            depname="${dep}"
        fi

        if [[ "${prefix}" == 's!' ]]; then
            suggests+=("${depname}")
        else
            recommends+=("${depname}")
        fi
    done
}

# vim: set sw=4 expandtab:
