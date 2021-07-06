verify_dependencies() {
    if [[ "${1}" != "" ]]; then
        msg "Checking build dependencies..."

        local apt_output=$(eval apt-get satisfy -sq ${@} 2>&1)
        local apt_uninstallable_packages="$(echo "${apt_output}" | \
                                            grep -o 'Depends: .*' | \
                                            sed 's|.*Depends: ||g' | \
                                            sed 's| but [^ ]* is to be installed||g' | \
                                            sed 's|$|,|g' | \
                                            xargs |
                                            head -c -2)"

        if [[ "${apt_uninstallable_packages}" != "" ]]; then
            error "The following build dependencies are missing: ${apt_uninstallable_packages}"
            exit 1
        fi

        apt_packages_to_install="$( echo "${apt_output}" | grep '^  [[:alnum:]]' | xargs)" || true

        if [[ "${apt_packages_to_install}" != "" ]]; then
            error "The following build dependencies are missing: ${apt_packages_to_install}"
            exit 1
        fi

    fi
}
