verify_dependencies() {
    if [[ "${1}" != "" ]]; then
        msg "Checking build dependencies..."

        local apt_output=$(apt-get satisfy -sq ${@} 2>&1)
        local apt_uninstallable_packages="$(echo "${apt_output}" | grep -o '[^ ]* but it is not installable' | sed 's| but it is not installable||g' | xargs)"

        if [[ "${apt_uninstallable_packages}" != "" ]]; then
            local uninstallable_package_list=$(echo "${apt_uninstallable_packages}" | xargs | sed 's| |, |g')

            error "The following build dependencies are missing: ${uninstallable_package_list}"
            exit 1
        fi

        apt_packages_to_install="$( echo "${apt_output}" |
                                    grep -Ev 'Conf |Inst ' |
                                    tr -d '\n' |
                                    grep -o 'packages will be install.*not upgraded\.' |
                                    sed 's|packages will be installed:||' |
                                    sed 's|[[:digit:]] upgraded.*||' |
                                    xargs |
                                    sed 's| |, |g' )" || true

        if [[ "${apt_packages_to_install}" != "" ]]; then
            error "The following build dependencies are missing: ${apt_packages_to_install}"
            exit 1
        fi

    fi
}
