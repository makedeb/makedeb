check_distro_dependencies() {
    msg "Setting distro-specific relationships..."
    export distro_version="$(lsb_release -cs)"

    for i in depends optdepends conflicts provides replaces makedepends optdepends; do
        package_data="$(eval echo \${${distro_version}_${i}[@]})"
        package_data_commas="$(echo "${package_data}" | sed 's| |, |g')"

        if [[ "${package_data}" != "" ]]; then
            msg2 "Setting \$${i} to ${package_data_commas}..."
            unset depends
            export "${i}"="${package_data}"

            unset package_data package_data_commas
        fi
    done
}
