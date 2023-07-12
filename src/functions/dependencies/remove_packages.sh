remove_packages() {
    sudo apt-get remove "${APTARGS[@]}" "${@}"
    return $?
}

# vim: set syntax=bash ts=4 sw=4 expandtab:
