version_info() {
    echo "makedeb ${makedeb_package_version}"
    echo "${makedeb_release_type^} Release"
    echo "Installed from ${makedeb_release_target^^}"
}
