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

        apt_package_dependencies="$(echo "${apt_output}" |
                                    sed 's|$| |g' |
                                    tr -d '\n' |
                                    grep -o 'The following NEW packages will be installed:.*[[:digit:]] upgraded' |
                                    sed 's|The following NEW packages will be installed:||' |
                                    sed 's|[[:digit:]] upgraded||' |
                                    xargs)"

        if [[ "${apt_package_dependencies}" != "" ]]; then
            error "The following build dependencies are missing: ${apt_package_dependencies}"
            exit 1
        fi

    fi
}
