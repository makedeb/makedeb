verify_dependencies() {
    if [[ "${depends}" != "" || "${makedepends}" != "" || "${checkdepends}" != "" ]]; then
        export apt_output="$(apt list ${depends[@]} ${makedepends[@]} ${checkdepends[@]} 2> /dev/null)"

        for i in ${depends[@]} ${makedepends[@]} ${checkdepends[@]}; do
            if [[ "$(echo "${apt_output}" | grep "^${i}/" | grep -E "$(dpkg --print-architecture)|all" | grep '\[installed')" == "" ]]; then
                export apt_not_installed_temp+=" ${i}"
            fi
        done

        export apt_not_installed="$(echo "${apt_not_installed_temp}" | xargs | sed 's| |, |g')"
        unset apt_not_installed_temp

        if [[ "${apt_not_installed}" != "" ]]; then
            error "The following packages are marked as build dependencies, but aren't installed: ${apt_not_installed}."
            exit 1
        fi
    fi
}
