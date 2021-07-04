version_info() {
    makepkg_package_version="$(makepkg --version | awk NR=="1" | awk '{print $3}')"

    echo "makedeb (${makedeb_package_version})"
    echo "makepkg (${makepkg_package_version})"
}
