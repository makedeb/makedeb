version_info() {
    if [[ "${makedeb_release_target}" == "local" ]]; then
        declare makedeb_release_target="APT"
    fi

    echo "makedeb ${makedeb_package_version}"
    echo "${makedeb_release_type^} Release"
    echo "Installed from ${makedeb_release_target}"
}
