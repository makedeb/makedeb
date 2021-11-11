version_info() {
  makepkg_package_version="$("${makepkg_package_name}" --version | awk NR=="1" | grep -o '([^)]*' | sed 's|(||')"

  echo "makedeb (${makedeb_package_version}) - ${makedeb_release_type^} Release"
  echo "makepkg (${makepkg_package_version})"
}
