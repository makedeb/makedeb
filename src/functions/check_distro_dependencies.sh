check_distro_dependencies() {
    export distro_version="$(lsb_release -cs)"

    for i in depends optdepends conflicts provides replaces makedepends optdepends; do
        local package_data="$(eval echo "\${${distro_version}_${i}[@]@Q}")"

        if [[ "${package_data}" != "" ]]; then
            eval declare "${i}=(${package_data})"
        fi
    done
}
