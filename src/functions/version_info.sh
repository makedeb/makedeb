version_info() {
    makepkg_package_version="$(makepkg --version | awk NR=="1" | awk '{print $3}')"

    echo "makedeb (${makedeb_package_version}) - ${makedeb_release_type^} Release"
    echo "makepkg (${makepkg_package_version})"
}
