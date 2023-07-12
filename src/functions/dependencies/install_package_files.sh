install_package_files() {
    (( REINSTALL )) && APTARGS+=('--reinstall')
    (( ASDEPS )) && APTARGS+=('--mark-auto')
    sudo apt-get install "${APTARGS[@]}" "${@}"
    return $?
}


# vim: set syntax=bash ts=4 sw=4 expandtab:
