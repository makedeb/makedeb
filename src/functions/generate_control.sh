generate_control() {
  echo "Generating control file..."
  export_control "Package:" "${pkgname}"
  export_control "Description:" "${pkgdesc}"
  export_control "Source:" "${source}"
  export_control "Version:" "${pkgver}"

  convert_arch
  export_control "Architecture:" "${makedeb_arch}"

  export_control "Maintainer:" "$(cat ../../${FILE} | grep '\# Maintainer\:' | sed 's/# Maintainer: //' | xargs | sed 's|>|>, |g')"
  export_control "Depends:" "${new_depends[@]}"
  export_control "Suggests:" "${new_optdepends[@]}"
  export_control "Conflicts:" "${new_conflicts[@]}"

  echo "" >> DEBIAN/control
}
