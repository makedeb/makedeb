check_distro_dependencies() {
    local distro_codename="$(lsb_release -cs)" \
          variable_ref="" \
          package_data=""

    # Skip checking of distribution dependencies if the system's codename isn't a
    # valid variable name.
    bad_variable_chars="$(echo "${distro_codename}" | sed 's|^[a-zA-Z_][a-zA-Z0-9_]*||')"

    if [[ "${bad_variable_chars}" != "" ]]; then
        return
    fi

    # Continue with checking of variables.
    for i in depends optdepends conflicts provides replaces makedepends optdepends; do
        distro_variable_string="${distro_codename}_${i}[@]"
        distro_variable_data=("${!distro_variable_string}")

        if [[ "${distro_variable_data}" != "" ]]; then
            create_array "${i}" "${distro_variable_data[@]}"
        fi
    done
}

# vim: set syntax=bash ts=4 sw=4 expandtab:
