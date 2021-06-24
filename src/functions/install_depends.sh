install_depends() {
    # Get value of make_depends / check_depends
    local depends_value=$(eval echo \${$1})

    if [[ "${depends_value}" != "" ]]; then
        # Run xargs so $new_depends doesn't print a double space
        msg "Checking ${2} dependencies..." | xargs

        local apt_output=$(apt list ${depends_value} 2> /dev/null | sed 's|Listing...||')

        for i in ${depends_value}; do
            # Check if package can be found
            if ! echo "${apt_output}" | grep "^${i}/" | grep -E "$(dpkg --print-architecture)|all" &> /dev/null; then
                export unknown_pkg+="${i} "

                # If not installed, add to list of packages to install
            elif ! echo "${apt_output}" | grep "^${i}/" | grep -E "$(dpkg --print-architecture)|all" | grep '\[installed' &> /dev/null; then
                export "apt_${2}depends"+="${i} "

            fi
        done

        # Exit if a package couldn't be found
        [[ "${unknown_pkg}" != "" ]] && {
            error "Couldn't find the following packages: $(echo ${unknown_pkg} | xargs | sed 's| |, |g')"
            exit 1
        }

        # If dependency list isn't empty, install packages
        if [[ $(eval echo \${apt_${2}depends}) != "" ]]; then
            msg "Installing ${2} dependencies..." | xargs

            if eval sudo apt install \${apt_${2}depends}; then
                eval sudo apt-mark auto \${apt_${2}depends}

            else
                error "Couldn't install packages."
                msg "Cleaning up..."
                eval sudo apt remove \${apt_${2}depends} || true
                exit 1
            fi
        fi
    fi
}
